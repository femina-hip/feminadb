Feminadb::Application.routes.draw do
  namespace :admin do
    resources :customer_types, :except => :show
    resources :delivery_methods, :except => :show
    resources :districts
    resources :regions
    resources :users
  end

  resources :clubs

  resources :customers do
    collection do
      get :similar
    end
    member do
      post :tag
    end
    resources :standing_orders, :controller => 'customer_standing_orders'
    resources :waiting_orders, :controller => 'customer_waiting_orders' do
      member do
        post :convert_to_standing_order
      end
    end
    resources :orders, :controller => 'customer_orders'
    resources :notes, :controller => 'customer_notes'
    resource :club
  end

  get 'tags/auto_complete' => 'tag#auto_complete_for_tag_name'

  resources :publications do
    collection do
      get :district_breakdown
    end

    member do
      get :issue_district_breakdown
    end
  end

  resources :issues do
    member do
      get :orders_in_district
      get :show_distribution_quote_request
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
  resources :report_graphs, :only => :show
  resources :bulk_order_creators, :only => [ :new, :create ]

  get 'data/issues' => 'data/issues#index', :as => 'data_issues'

  get 'help(/:doc)' => 'helps#show', :as => 'help'

  get 'oauth2callback' => 'auth#callback'
  get 'logout' => 'auth#logout'

  root :to => 'customers#index'
end
