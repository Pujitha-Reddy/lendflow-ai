Rails.application.routes.draw do
  resources :users, only: [:create, :show] do
    resource :credit_profile, only: [:create, :show], controller: "credit_profiles"
  end

  resources :loan_applications, only: [:create, :show] do
    resource :decision, only: [:create, :show], controller: "loan_decisions"
  end

  post "/ai/chat", to: "ai_assistant#chat"
end