Rails.application.routes.draw do
  get 'scouts' => "scouts#index", as: :scouts
  post 'scouts' => "scouts#create"
  get 'scouts/:id/edit' => 'scouts#edit', as: :edit_scout
  patch 'scouts/:id' => 'scouts#update', as: :scout

  resources :match, only: [:index]
  resources :salesperson, only: [:index]

  root 'salesperson#index'
end
