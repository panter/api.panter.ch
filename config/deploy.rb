# config valid only for current version of Capistrano
lock '3.8.1'

set :application, 'api.panter.ch'
set :repo_url, 'git@github.com:panter/api.panter.ch.git'

append :linked_files, '.env', 'config/salaries.yml'

append :linked_dirs, 'system/repositories'
