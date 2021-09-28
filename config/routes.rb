# Language: Ruby, Level: Level 4

Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:index]
  resources :personal_messages, only: [:new, :create]
  resources :conversations, only: [:index, :show]

  root 'conversations#index'
end
