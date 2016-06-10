Rails.application.routes.draw do
  devise_for :users

  root 'static#index'

  namespace :profile, module: false do
    get '/' => 'history#index'
    resources :history, only: [:index] do
      member do
        get :timeline
        get :card_stats
      end
    end
    resources :arena, only: [:index]
    resources :results, only: [:create, :show, :update, :destroy] do
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
      resources :decks, only: :index
    end
  end

  resources :users, only: [:create, :show] do
    patch :rename
  end

  resources :one_time_auth, only: [:create, :show]

  resources :notifications, only: [] do
    member do
      put :mark_as_read
    end
  end
end
