Rails.application.routes.draw do
  resource :code, only: [:show], controller: 'code'
  resource :staff, only: [:show], controller: 'staff'
  resource :salary, only: [:show], controller: 'salary'
end
