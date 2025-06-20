Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "home#index"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, controllers: { registrations: "users/registrations" }

  # Exports
  get "exports" => "exports#index", as: :exports
  post "exports" => "exports#export", as: :export
  get "exports/preview" => "exports#preview", as: :export_preview

  # Foods
  resources :foods do
    collection do
      patch :pager_rows_changed
    end
  end

  # Health conditions
  resources :health_conditions do
     collection do
      patch :pager_rows_changed
    end
  end

  # Health goals
  resources :health_goals do
     collection do
      patch :pager_rows_changed
    end
  end

  # Medications
  resources :medications, only: [ :index, :show, :destroy ] do
    collection do
      patch :pager_rows_changed
    end
  end

  # Imports
  get "imports" => "imports#index", as: :imports
  post "upload" => "imports#upload", as: :import_upload
  post "imports" => "imports#import", as: :import

  # User foods
  resources :user_foods, only: [ :create, :destroy, :index, :new ] do
    collection do
      get :select_multiple
      post :add_multiple
      patch :pager_rows_changed
    end
  end

  # User health conditions
  resources :user_health_conditions, only: [ :create, :destroy, :index, :new ] do
    collection do
      get :select_multiple
      post :add_multiple
      patch :pager_rows_changed
    end
  end

  # User health goals
  resources :user_health_goals do
    collection do
      get :select_multiple
      post :add_multiple
      patch :pager_rows_changed
    end
    member do
      patch :update_importance
    end
  end

  # User medications
  resources :user_medications, only: [ :create, :destroy, :index, :new, :show, :edit, :update ] do
    collection do
      get :search
      patch :pager_rows_changed
    end
  end

   # User stats
   resources :user_stats do
     collection do
       patch :pager_rows_changed
     end
   end

   # User supplements
   resources :user_supplements do
     member do
       post :add_component
       delete :remove_component
     end
     collection do
       get :select_multiple
       post :add_multiple
       patch :pager_rows_changed
     end
   end

   # User meal prompts
   resources :user_meal_prompts, only: [ :show, :update, :destroy ] do
     collection do
       get :wizard
       get :step_1
       get :step_2
       get :step_3
       get :step_4
       post :update_step
       post :generate
     end
   end
end
