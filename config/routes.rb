Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/register", to: "users#new"
  post "/users", to: "users#create"
  get "/profile", to: "users#show", as: :profile

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "/posts/category/:category_id", to: "posts#category", as: "category_posts"

  resources :posts do
    resources :comments, only: [ :create, :edit, :update ] do
      post "reply", on: :member
      resource :comment_reaction, only: [ :create, :destroy ]
    end

    resources :reports, only: [ :new, :create ]
  end

  resources :comments, only: [] do
    resources :reports, only: [ :new, :create ]
  end

  resources :reports, only: [ :index ]

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "posts#index"
end
