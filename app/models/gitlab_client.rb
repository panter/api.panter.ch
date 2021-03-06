class GitlabClient
  # some repositories exist on github as well.
  REPOSITORY_BLACKLIST = (ENV['GITLAB_REPO_BLACKLIST'] || '').split(',')

  def initialize
    Gitlab.endpoint = ENV['GITLAB_URL']
    Gitlab.private_token = ENV['GITLAB_PRIVATE_TOKEN']
  end

  def projects
    @projects ||=
      begin
        projects = paginate(:projects, options: { scope: :all })

        # exclude projects without proper repositories
        # `merge_requests_enabled` seems equivalent to if a repository exists
        projects
          .select { |project| project.merge_requests_enabled }
          .reject { |project| REPOSITORY_BLACKLIST.include?(project.path_with_namespace) }
          .reject { |project| ProjectFilter.deprecated?(project) }
      end
  end

  def projects_active_today
    projects.select { |project| Date.parse(project.last_activity_at) == Date.today }
  end

  def commits_per_project
    @commits_per_project ||=
      begin
        commits = {}
        projects_active_today.each do |project|
          commits[project.id] = paginate(
            :commits,
            args: [project.id],
            select_condition: -> (page) { Date.parse(page.created_at) == Date.today }
          )
        end

        commits
      end
  end

  def commits
    commits_per_project.values.inject(&:+) || []
  end

  # @return [Fixnum] the number of today's commits
  def commits_count
    commits.length
  end

  # @return [Hash{Symbol=>Fixnum}] the number of line additions
  #   and deletions in the form `{additions: <Fixnum>, deletions: <Fixnum>}`
  def line_changes
    @line_changes ||=
      begin
        line_changes = { additions: 0, deletions: 0 }

        commits_per_project.each do |project, commits|
          commits.each do |commit|
            Gitlab.commit_diff(project, commit.id).each do |diff|
              change = diff.diff[/@@ (.+) @@/, 1]
              # diff may not contain line changes (e.g. file rename)
              if change
                line_changes[:deletions] += change[/-\d+,(\d+)/, 1].to_i
                line_changes[:additions] += change[/\+\d+,(\d+)/, 1].to_i
              end
            end
          end
        end

        line_changes
      end
  end

  # @return [Gitlab::ObjectifiedHash] Today's comments on pull requests.
  # We use the merge request *notes* endpoint
  # (http://doc.gitlab.com/ce/api/notes.html#list-all-merge-request-notes)
  # instead of the merge request *comments* endpoint, as the latter doesn't
  # contain any dates in the response.
  def pull_request_comments
    @pull_request_comments ||=
      begin
        comments = []
        projects.each do |project|
          next unless project.merge_requests_enabled

          merge_requests = paginate(
            :merge_requests,
            args: [project.id],
            options: { order_by: :updated_at },
            select_condition: -> (merge_request) { Date.parse(merge_request.updated_at) == Date.today }
          )

          merge_requests.each do |merge_request|
            comments += paginate(
              :merge_request_notes,
              args: [project.id, merge_request.iid],
              select_condition: -> (comment) {
                !comment.system &&
                Date.parse(comment.created_at) == Date.today
              }
            )
          end
        end

        comments
      end
  end

  # @return [Fixnum] the number of today's pull request comments
  def pull_request_comments_count
    pull_request_comments.length
  end

  # @return [Hash{Symbol=>Integer}] the languages with the overall absolute count
  #   as value and the language name as key.
  def languages
    @languages ||= LocalRepository::Languages.new(projects.map(&:name)).absolute_values
  end

  # @return [Hash{Symbol=>Integer}] the frameworks with the overall absolute count
  #   as value and the language name as key.
  def frameworks
    @frameworks ||= LocalRepository::Frameworks.new(projects.map(&:name)).absolute_values
  end

  private

  def paginate(method, args: [], options: {}, select_condition: nil)
    options.merge!(per_page: 100, page: 0)

    results = []
    loop do
      page_result = Gitlab.send(method, *(args + [options]))

      break if page_result.empty?

      results += page_result

      # 1) don't retrieve new pages if the condition isn't met anymore
      break if select_condition && !select_condition.call(page_result.last)

      options[:page] = options[:page] + 1
    end

    # 2) although 1) has cancelled any more fetching of pages, we still
    # need to filter out the unmatched entries
    results = select_condition ? results.select(&select_condition) : results

    # sometimes page 0 and 1 contain the same entries
    results.uniq(&:id)
  end
end
