Rails.application.routes.draw do
  resources :articles
  get 'pages/index'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "pages#index"
  get 'sign-in-development/:id', to: 'pages#sign_in_development', as: :sign_in_development

  get 'pages/unsubscribe', to: "pages#unsubscribe", as: :unsubscribe
  post 'pages/unsubscribe', to: "pages#unsubscribe_post", as: :unsubscribe_post
end
