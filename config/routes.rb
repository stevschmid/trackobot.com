Rails.application.routes.draw do
  devise_for :users

  root 'results#index'
  resources :results

  resources :users, only: [:create, :show]
  resources :one_time_auth, only: [:create, :show]
end
