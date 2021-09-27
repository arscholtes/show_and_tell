# Language: Ruby, Level: Level 4
Rails.application.routes.draw do
  root 'conversations#index'
  resources :personal_messages, only: [:create]
  resources :conversations, only: [:index, :show]
  resources :users, only: [:index]
  resources :personal_messages, only: [:new, :create]
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
