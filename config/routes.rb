Rails.application.routes.draw do
  root "pages#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :images, only: [:create, :index, :destroy] do
  collection do
    post :status
  end
end

  get "gallery", to: "pages#gallery"
  resources :articles, only: [:index, :show, :create, :update, :destroy]
  get "about", to: "pages#about"
  patch "about", to: "pages#update_about"
  get "recruitment", to: "pages#recruitment"
  patch "recruitment", to: "pages#update_recruitment"
  get "rules", to: "pages#rules"
  patch "rules", to: "pages#update_rules"
  get "contact", to: "pages#contact"

  get "up" => "rails/health#show", as: :rails_health_check
  # お問い合わせ用のルート
  get  'contact', to: 'contacts#new'
  post 'contact', to: 'contacts#create'
  # ルーティングにマッチしなかった不審なアクセスを、ログを汚さずに404を返す
  match '*path', to: proc { [404, { 'Content-Type' => 'text/plain' }, ['Not Found']] }, via: :all
end
