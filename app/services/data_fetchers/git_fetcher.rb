class GitFetcher
  def initialize
    @github = Github.new
    @gitlab = GitlabClient.new
  end

  def run
    commits
    pr_comments
    line_changes
    languages
    frameworks
  end

  private

  attr_reader :github, :gitlab

  def commits
    DataStore.set('commits', count: github.commits_count + gitlab.commits_count)
  end

  def pr_comments
    DataStore.set(
      'pull-request-comments',
      count: github.pull_request_comments_count + gitlab.pull_request_comments_count
    )
  end

  def line_changes
    DataStore.set(
      'line-additions',
      count: github.line_changes[:additions] + gitlab.line_changes[:additions],
    )

    DataStore.set('line-deletions',
      count: github.line_changes[:deletions] + gitlab.line_changes[:deletions]
    )
  end

  def languages
    languages = github.languages
    languages.merge!(gitlab.languages) { |key, value1, value2| languages[key] = value1 + value2 }

    languages = PercentCalculator.to_percent(languages)

    languages = languages.map do |language, percent|
      [language, "#{percent}%"]
    end.to_h

    DataStore.set('programming-languages', languages)
  end

  def frameworks
    frameworks = github.frameworks
    frameworks.merge!(gitlab.frameworks) { |key, value1, value2| frameworks[key] = value1 + value2 }

    frameworks = PercentCalculator.to_percent(frameworks)

    frameworks = frameworks.map do |framework, percent|
      [framework, "#{percent}%"]
    end.to_h

    DataStore.set('frameworks', frameworks)
  end
end
