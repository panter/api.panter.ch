class Github
  # we exclude projects that contain too much vendor
  # stuff. this distorts our statistics. E.g. wordpress
  # repositories.
  # also, some repositories exist in gitlab as well.
  REPOSITORY_BLACKLIST = (ENV['GITHUB_REPO_BLACKLIST'] || '').split(',')

  ORGANIZATION_NAME = ENV['GITHUB_ORGANIZATION_NAME']

  attr_reader :client

  def initialize
    @client = Octokit::Client.new(:login => ENV['GITHUB_USER'], :access_token => ENV['GITHUB_TOKEN'])
  end

  # @return http://www.rubydoc.info/github/pengwynn/octokit/Octokit/Client/Events#organization_events-instance_method
  def events
    @events ||=
      begin
        events = client.organization_events(ORGANIZATION_NAME)

        # get all today's events
        last_response = client.last_response
        while events.last.created_at.to_date == Date.today && last_response.rels[:next]
          last_response = last_response.rels[:next].get
          events += last_response.data
        end
        events.select { |event| event.created_at.to_date == Date.today }
      end
  end

  def commits_per_project
    commits_per_project = Hash.new { |hash, key| hash[key] = [] }

    events.select { |event| event.type == 'PushEvent' }.each do |push_event|
      repo = push_event.repo.name
      commits_per_project[repo] += push_event.payload.commits
    end

    commits_per_project
  end

  def commits
    commits_per_project.values.inject(&:+) || []
  end

  # @return [Fixnum] the number of commits
  # @see {#events} for the range of events that are considered.
  def commits_count
    commits
      .map(&:sha)
      .uniq
      .length
  end

  # @return [Fixnum] the number of pull request comments
  def pull_request_comments_count
    events
      .select { |event|
        # inline-diff comments
        event.type == 'PullRequestReviewCommentEvent' ||
        # comments in the main thread
        (event.type == 'IssueCommentEvent' && event.payload.issue.pull_request)
      }
      .length
  end

  # all repositories
  #
  # @return http://www.rubydoc.info/github/pengwynn/octokit/Octokit/Client/Organizations#organization_repositories-instance_method
  def repositories
    @repositories ||=
      begin
        repositories = client.organization_repositories(ORGANIZATION_NAME)
        last_response = client.last_response
        while last_response.rels[:next]
          last_response = last_response.rels[:next].get
          repositories += last_response.data
        end

        repositories
          .reject { |repository| REPOSITORY_BLACKLIST.include?(repository.full_name) }
          .reject { |project| ProjectFilter.deprecated?(project) }
      end
  end

  # all owned repositories (i.e. excluding forks)
  #
  # @return http://www.rubydoc.info/github/pengwynn/octokit/Octokit/Client/Organizations#organization_repositories-instance_method
  def own_repositories
    @own_repositories ||= repositories.reject(&:fork)
  end

  # @return [Hash{Symbol=>Fixnum}] the number of line additions
  #   and deletions in the form `{additions: <Fixnum>, deletions: <Fixnum>}`
  def line_changes
    @line_changes ||=
      begin
        line_changes = { additions: 0, deletions: 0 }

        commits_per_project.each do |project, commits|
          commits.each do |commit|
            full_commit = client.commit(project, commit.sha)
            line_changes[:deletions] += full_commit.stats[:deletions]
            line_changes[:additions] += full_commit.stats[:additions]
          end
        end

        line_changes
      end
  end

  # @return [Hash{Symbol=>Integer}] the languages with the overall absolute count
  #   as value and the language name as key.
  def languages
    @languages ||= LocalRepository::Languages.new(own_repositories.map(&:name)).absolute_values
  end

  # @return [Hash{Symbol=>Integer}] the frameworks with the overall absolute count
  #   as value and the language name as key.
  def frameworks
    @frameworks ||= LocalRepository::Frameworks.new(own_repositories.map(&:name)).absolute_values
  end
end
