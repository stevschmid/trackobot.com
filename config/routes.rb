Rails.application.routes.draw do
  devise_for :users

  root 'results#index'
  resources :results
end
