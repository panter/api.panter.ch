class LocalRepository::Base
  attr_reader :directories

  def initialize(directories)
    @directories = directories
  end

  def valid_directories
    directories
      .map { |directory| File.join(Configuration::GIT_REPOSITORY_DIRECTORY, directory) }
      .select { |directory| Dir.exist?(directory) }
  end
end
