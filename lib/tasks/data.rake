desc 'Retrieves all data from all sources'
task data: [:'data:git', :'data:controllr']

namespace :data do
  desc 'Retrieves all data from the git repositories (github and gitlab)'
  task git: :environment do
    GitFetcher.new.run
  end

  desc 'Retrieves all data from the controllr'
  task controllr: :environment do
    ControllrFetcher.new.run
  end

  namespace :controllr do
    desc 'Retrieves the salary data'
    task salaries: :environment do
      ControllrFetcher.new.salaries
    end
  end

  desc 'Clears all the data'
  task clear: :environment do
    DataStore.clear
  end
end

desc 'Clones and updates all git repositories (github and gitlab)'
task clone_git_repositories: :environment do
  GitRepositoryCloner.new.run
end
