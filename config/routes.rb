Rails.application.routes.draw do
  devise_for :users

  root 'static#index'

  namespace :profile, module: false do
    get '/' => 'history#index'
    resources :history, only: [:index]
    resources :arena, only: [:index]
    resources :results, only: [:create, :show] do
      collection do
        delete :bulk_delete
      end
    end

    namespace :stats do
      resources :classes, only: :index
      resources :decks, only: :index
      resources :arena, only: :index
    end

    namespace :settings do
      resource :api, only: [:show, :update]
      resources :decks
    end
  end

  resources :users, only: [:create, :show] do
    patch :rename
  end

  resources :one_time_auth, only: [:create, :show]

  resources :feedbacks

  resources :notifications, only: [] do
    member do
      put :mark_as_read
    end
  end
end
