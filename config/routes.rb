Rails.application.routes.draw do
  root "pages#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :images, only: [:create, :index, :destroy]
  resources :images, only: [:create, :destroy] do
  collection do
    post :status # または get :status でも可
  end
end

  get "gallery", to: "pages#gallery"
  get "articles", to: "articles#index"
  post "articles", to: "articles#create"
  patch "articles/:id", to: "articles#update", as: :article
  delete "articles/:id", to: "articles#destroy"
  get "about", to: "pages#about"
  patch "about", to: "pages#update_about"
  get "recruitment", to: "pages#recruitment"
  patch "recruitment", to: "pages#update_recruitment"
  get "rules", to: "pages#rules"
  patch "rules", to: "pages#update_rules"
  get "contact", to: "pages#contact"

  get "up" => "rails/health#show", as: :rails_health_check
  resources :articles
  # お問い合わせ用のルート
  get  'contact', to: 'contacts#new'
  post 'contact', to: 'contacts#create'
end
