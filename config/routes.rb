Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get "/api/v1/items/find_all", to: "api/v1/items#find_all"
  get "/api/v1/merchants/find", to: "api/v1/merchants#find"

  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show]
      resources :items do
        member do
          resources :merchant, controller: :merchant_items
        end
      end
    end
  end

  get "/api/v1/merchants/:id/items", to: "api/v1/merchant/items#index"
end
