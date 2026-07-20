Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication apis
  post "/users", to: "user#create"
  get "/me", to: "user#me"
  post "/signup/verify", to: "user#verify_signup"
  post "/signup/resend-otp", to: "user#resend_otp"
  post "/password/forgot", to: "auth#forgot_password"
  post "/password/verify-otp", to: "auth#verify_password_reset_otp"
  post "/password/reset", to: "auth#reset_password"
  post "/login", to: "auth#login"
  delete "/logout", to: "auth#logout"

  # Google oauth
  get "/auth/:provider/callback", to: "auth#omniauth"
  post "/auth/:provider/callback", to: "auth#omniauth"
  get "/auth/failure", to: "auth#omniauth_failure"
  get "/login/google", to: "auth#google_login"

  # Notes cruds
  resources :note

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
