Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      get "items/find_all", to: "items#find_all"
      resources :merchants, only: [:index, :show] do
        collection do
          get 'find', to: 'merchants#find'
        end
      
        resources :items, only: [:index]
      end
      resources :items do
        member do
          get "merchant", to: "items#merchant"
        end
      end
    end
  end
end
