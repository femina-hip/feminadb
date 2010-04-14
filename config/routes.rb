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
    resources :standing_orders
    resources :waiting_orders
    resources :orders
    resources :notes, :controller => 'CustomerNotes'
    resource :club
  end
  match 'customers/:customer_id/tag/create' => 'Tag#create'
  match 'tag/auto_complete' => 'tag#auto_complete_for_tag_name'

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
        get :show_special_order_lines
        get :show_packing_instructions
        get :show_distribution_quote_request
        get :show_distribution_order
        get :show_distribution_list
      end

      resources :notes

      resources :orders, :controller => 'issue_orders' do
        member do
          post :set_order_num_copies
        end
      end
    end

    resources :standing_orders, :controller => 'publication_standing_orders'
    resources :waiting_orders, :controller => 'publication_waiting_orders'
  end

  resources :modifications, :only => :index
  resources :reports, :only => [ :index, :show ]
  resources :report_graphs, :only => [ :show ]

  resources :special_orders do
    member do
      put :approve
      put :deny
      put :complete
    end

    resources :notes, :controller => 'special_order_notes'
  end

  resource :inventory
  resource :help

  match 'standing_orders_to_orders/:id' => 'standing_orders_to_orders#start_task', :as => 'generate_orders_from_standing_orders', :method => :post
  match 'bulk_order/run' => 'bulk_order#run', :as => 'run_bulk_order'
  match 'bulk_order/prepare' => 'bulk_order#prepare', :as => 'prepare_bulk_order'

  match 'login(/:return_to)' => 'account#login', :as => 'login'
  match 'logout(/:return_to)' => 'account#logout', :as => 'logout'

  root :to => 'customers#index'
  match ':controller/service.wsdl' => '#wsdl'
end
