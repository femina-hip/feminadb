Feminadb::Application.routes.draw do
  namespace :admin do
    resources :customer_types
    resources :delivery_methods
    resources :districts
    resources :regions
    resources :users
    resources :warehouses
  end

  resources :clubs

  resources :customers do
    collection do
      get :similar
    end
    member do
      post :tag, :controller => 'Tags', :action => 'create'
    end
    resources :standing_orders, :controller => 'customer_standing_orders'
    resources :waiting_orders, :controller => 'customer_waiting_orders' do
      member do
        post :convert_to_standing_order
      end
    end
    resources :orders, :controller => 'customer_orders'
    resources :notes, :controller => 'CustomerNotes'
    resource :club
  end

  match 'tags/auto_complete' => 'tag#auto_complete_for_tag_name'

  resources :publications do
    collection do
      get :district_breakdown
    end

    member do
      get :issue_district_breakdown
    end

    resources :issues do
      member do
        get :orders_in_district
        get :show_packing_instructions
        get :show_distribution_quote_request
        get :show_distribution_order
        get :show_distribution_list
      end

      resources :notes
      resources :orders, :controller => 'issue_orders'
    end

    resources :standing_orders, :controller => 'publication_standing_orders'
    resources :waiting_orders, :controller => 'publication_waiting_orders' do
      member do
        post :convert_to_standing_order
      end
    end
  end

  resources :modifications, :only => :index
  resources :reports, :only => [ :index, :show ]
  resources :report_graphs, :only => :show
  resources :bulk_order_creators, :only => [ :new, :create ]

  resource :inventory, :controller => 'inventory' do
    post :set_issue_inventory_comment
    post :set_issue_num_copies_in_house
    post :set_warehouse_issue_box_size_num_boxes
  end

  match 'data/issues' => 'data/issues#index', :as => 'data_issues'

  match 'help(/:doc)' => 'helps#show', :as => 'help'

  match 'login(/:return_to)' => 'account#login', :as => 'login'
  match 'logout(/:return_to)' => 'account#logout', :as => 'logout'

  root :to => 'customers#index'
  match ':controller/service.wsdl' => '#wsdl'
end
