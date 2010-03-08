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
    resources :standing_orders
    resources :waiting_orders
    resources :orders
    resources :notes
    resource :club
  end
  match 'customers/:customer_id/tag/create' => 'Tag#create'
  match 'tag/auto_complete' => 'tag#auto_complete_for_tag_name'

  resources :publications do
    resources :issues do
      resources :notes
      resources :orders do
        member do
          post :set_order_num_copies
        end
      end
    end

    resources :standing_orders
    resources :waiting_orders
  end

  resources :issues_select do
    collection do
      get :browse
    end
    member do
      post :select
    end
  end

  resources :modifications
  resources :reports

  resources :special_orders do
    resources :notes
  end

  resource :inventory
  resource :help

  match 'bulk_order/prepare' => 'bulk_order#prepare', :as => 'prepare_bulk_order'

  match 'login(/:return_to)' => 'account#login', :as => 'login'
  match 'logout(/:return_to)' => 'account#logout', :as => 'logout'

  root :to => 'customers#index'
  match ':controller/service.wsdl' => '#wsdl'
end
