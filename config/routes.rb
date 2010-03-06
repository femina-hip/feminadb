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

  resources :special_orders do
    resources :notes
  end

  resource :help

  root :to => 'customers#index'
  match ':controller/service.wsdl' => '#wsdl'
  match ':controller(/:action(/:id))'
end
