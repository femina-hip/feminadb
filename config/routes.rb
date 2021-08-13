Rails.application.routes.draw do
  namespace :admin do
    resources :customer_types, :except => :show
    resources :delivery_methods, :except => :show
    resources :regions
    resources :users
    resources :surveys, only: [ :index, :new, :create, :destroy ]
    resources :tags
  end

  get '/councils/by-region.json', controller: 'councils', action: 'by_region_json'

  resources :customers do
    collection do
      get :similar
      get :autocomplete
      get :bulk_rename_council
      post :do_bulk_rename_council
    end
    member do
      post 'sms-numbers/:attribute', action: 'add_sms_number', as: 'add_sms_number'
      delete 'sms-numbers/:attribute/:sms_number', action:'remove_sms_number', as: 'remove_sms_number'
    end
    resources :sms_messages, only: :index
    resources :standing_orders, :controller => 'customer_standing_orders'
    resources :orders, controller: 'customer_orders', only: [ :new, :create, :destroy ]
    resources :notes, :controller => 'customer_notes'
    resources :telerivet_links, only: [ :new, :edit, :create, :destroy ]
  end

  resources :publications

  resources :issues do
    member do
      get :show_distribution_order
      get :show_distribution_list
      get :show_num_copies_by_council
    end

    resources :notes, controller: 'issue_notes'
    resources :orders, controller: 'issue_orders', only: :index
  end

  resources :reports, only: :show

  resources :standing_orders
  resources :survey_responses, only: [ :edit, :update ]

  resources :tags, only: [ :index ] do
    member do
      post :tag_customers
      post :untag_customers
    end
  end

  resources :modifications, only: :index
  resources :orders, only: [ :new, :create, :edit, :update ]
  resources :bulk_order_creators, :only => [ :new, :create ]

  resource :map, only: :show

  get 'telerivet_links/new' => 'telerivet_links#help'

  get 'help(/:doc)' => 'helps#show', :as => 'help'

  get 'oauth2callback' => 'auth#callback'
  get 'logout' => 'auth#logout'
  get 'healthz' => 'application#healthz'

  root :to => 'customers#index'
end
