Rails.application.routes.draw do
  devise_for :users

  root 'static#index'

  namespace :profile, module: false do
    get '/' => 'history#index'
    resources :history, only: [:index]
    resources :arena, only: [:index]
    resources :stats, only: [:index]
    resources :results, only: [:create, :show]
  end

  resources :users, only: [:create, :show]
  resources :one_time_auth, only: [:create, :show]

  resources :feedbacks
end
