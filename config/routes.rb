Rails.application.routes.draw do
  devise_for :users
  #  controllers: {
  #   sessions: "users/sessions",
  #   registrations: "users/registrations"
  # }

  root to: "pages#home"
  get "knowledge", to: "pages#knowledge"
  get "settings", to: "pages#settings"

  resources :products, only: [:index, :new, :create, :show, :destroy] do
    resources :chats, only: [:new, :create, :destroy]
    resources :posts, only: [:index]
    member do
      post:refresh_dashboard
    end
  end

  resources :chats, only: [:show] do
    resources :messages, only: [:create]
  end

  get "up" => "rails/health#show", as: :rails_health_check

end
