# config valid only for current version of Capistrano
lock '3.9.0'

set :application, 'api.panter.ch'
set :repo_url, 'git@github.com:panter/api.panter.ch.git'

append :linked_files, '.env'

append :linked_dirs, 'system/repositories'
