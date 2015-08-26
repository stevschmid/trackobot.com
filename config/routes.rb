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
    resources :results, only: [:create, :show] do
      member do
        put :set_tags
      end
      collection do
        delete :bulk_delete
        put :bulk_update
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
