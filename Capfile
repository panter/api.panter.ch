# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile

# Define custom rails panter deploy requires as we don't need
# `capistrano/rails/migrations` and `capistrano/rails/assets`
# (see https://github.com/panter/panter-rails-deploy/blob/master/lib/panter-rails-deploy.rb)
if defined? Capistrano
  # We're running in Capistrano, only load tasks
  require 'capistrano/rbenv'
  require 'capistrano/rbenv_install'
  require 'capistrano/bundler'

  load 'panter-rails-deploy/../capistrano/tasks/panter-rails-deploy.rake'
else
  # We're running in the application, load supporting gems
  require 'unicorn-rails'
  require 'dotenv-rails'
end

require 'whenever/capistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
