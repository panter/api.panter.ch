desc 'Retrieves all data from all sources'
task data: [:'data:git', :'data:controllr']

namespace :data do
  desc 'Retrieves all data from the git repositories (github and gitlab)'
  task :git do
    GitFetcher.new.run
  end

  desc 'Retrieves all data from the controllr'
  task :controllr do
    ControllrFetcher.new.run
  end

  desc 'Clears all the data'
  task :clear do
    DataStore.clear
  end
end

desc 'Clones and updates all git repositories (github and gitlab)'
task :clone_git_repositories do
  GitRepositoryCloner.new.run
end
