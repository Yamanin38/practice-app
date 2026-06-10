Rails.application.routes.draw do
  root "pages#index"

  get "gallery", to: "pages#gallery"
  get "articles", to: "pages#articles"
  get "about", to: "pages#about"
  get "recruitment", to: "pages#recruitment"
  get "rules", to: "pages#rules"
  get "users", to: "pages#users"
  get "contact", to: "pages#contact"

  get "up" => "rails/health#show", as: :rails_health_check
end
