# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: [:create]

  resource :user, only: [:show, :destroy]

  resources :todos do # recommend only :index and :create to avoid duplication
    member do
      put 'complete'
      put 'incomplete'
    end
  end

  resources :todo_lists do # recommend shallow: true to avoid duplicated resources
    resources :todos do
      member do
        put 'complete'
        put 'incomplete'
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
