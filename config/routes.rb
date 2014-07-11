Rails.application.routes.draw do
  devise_for :users

  root 'static#index'

  namespace :profile, module: false do
    get '/' => 'history#index'
    resources :history, only: [:index]
    resources :arena, only: [:index]
    resources :stats, only: [:index]
    resources :results, only: [:create, :show]

    namespace :settings do
      resource :api, only: [:show, :update]
    end
  end

  resources :users, only: [:create, :show]
  resources :one_time_auth, only: [:create, :show]

  resources :feedbacks

  resources :notifications, only: [] do
    member do
      put :mark_as_read
    end
  end
end
