class Configuration
  GIT_REPOSITORY_DIRECTORY = Rails.root.join('system/repositories')

  class << self
    def controllr_enabled?
      module_enabled?('controllr')
    end

    def git_enabled?
      module_enabled?('git')
    end

    def server_command?
      %w(server s).include? ENV['RAILS_COMMAND']
    end

    private

    def module_enabled?(module_name)
      env_value = ENV['MODULES']
      if env_value
        env_value.include?(module_name)
      else
        true
      end
    end
  end
end
