Rails.application.routes.draw do
  resource :git, only: [:show], controller: 'git'
  resource :controllr, only: [:show], controller: 'controllr'
end
