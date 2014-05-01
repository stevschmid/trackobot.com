Rails.application.routes.draw do
  devise_for :users

  root to: redirect('/history')

  resources :history, only: [:index]
  resources :arena, only: [:index]
  resources :stats, only: [:index]

  resources :users, only: [:create, :show]
  resources :one_time_auth, only: [:create, :show]
end
