Rails.application.routes.draw do
  root 'results#index'

  resources :results
end
