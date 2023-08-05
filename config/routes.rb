Rails.application.routes.draw do

  # get '/', to: 'welcome#index'

  root 'welcome#index'

  resources :merchants do
    resources :dashboards, only: [:index]
    resources :items
    resources :invoices
    resources :bulk_discounts, only: [:index, :show]
  end

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants
    resources :invoices, except: [:new, :destroy]
  end
end
