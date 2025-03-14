Rails.application.routes.draw do
  get "user_health_conditions/index"
  get "user_health_conditions/show"
  get "user_health_conditions/new"
  get "user_health_conditions/edit"
  get "user_health_conditions/create"
  get "user_health_conditions/update"
  get "user_health_conditions/destroy"
  get "health_conditions/index"
  get "health_conditions/show"
  get "health_conditions/new"
  get "health_conditions/edit"
  get "health_conditions/create"
  get "health_conditions/update"
  get "health_conditions/destroy"
  resources :user_foods
  resources :food_qualifiers do
    collection do
      post "find_or_create"
    end
  end
  resources :foods do
    member do
      post "add_qualifier"
      delete "remove_qualifier"
    end
  end
  resources :health_conditions
  resources :user_health_conditions do
    resources :health_conditions, only: [ :create, :destroy ], controller: "user_health_conditions/health_conditions"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  root to: "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  devise_for :users
end
