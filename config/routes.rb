Feminadb::Application.routes.draw do
  namespace :admin do
    resources :customer_types, :except => :show
    resources :delivery_methods, :except => :show
    resources :districts
    resources :regions
    resources :users
  end

  resources :customers do
    collection do
      get :similar
      get :autocomplete
    end
    member do
      post 'sms-numbers/:attribute', action: 'add_sms_number', as: 'add_sms_number'
      delete 'sms-numbers/:attribute/:sms_number', action:'remove_sms_number', as: 'remove_sms_number'
    end
    resources :sms_messages, only: :index
    resources :standing_orders, :controller => 'customer_standing_orders'
    resources :waiting_orders, :controller => 'customer_waiting_orders' do
      member do
        post :convert_to_standing_order
      end
    end
    resources :orders, :controller => 'customer_orders'
    resources :notes, :controller => 'customer_notes'
  end

  resources :publications

  resources :issues do
    member do
      get :show_distribution_order
      get :show_distribution_list
    end

    resources :notes, :controller => 'issue_notes'
    resources :orders, :controller => 'issue_orders'
  end

  resources :standing_orders
  resources :waiting_orders do
    member do
      post :convert_to_standing_order
    end
  end

  resources :modifications, :only => :index
  resources :reports, :only => [ :index, :show ]
  resources :bulk_order_creators, :only => [ :new, :create ]

  resources :telerivet_links

  get 'help(/:doc)' => 'helps#show', :as => 'help'

  get 'oauth2callback' => 'auth#callback'
  get 'logout' => 'auth#logout'

  root :to => 'customers#index'
end
