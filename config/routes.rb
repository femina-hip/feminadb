ActionController::Routing::Routes.draw do |map|
  map.resource :admin do |admin|
    admin.resources :customer_types
    admin.resources :delivery_methods
    admin.resources :districts
    admin.resources :regions
    admin.resources :users
    admin.resources :warehouses
  end

  map.resources :clubs

  map.resources :customers do |customers|
    customers.resources :standing_orders, :controller => 'CustomerStandingOrders'
    customers.resources :waiting_orders, :controller => 'CustomerWaitingOrders'
    customers.resources :orders, :controller => 'CustomerOrders'
    customers.resources :notes, :controller => 'CustomerNotes'

    customers.resource :club

    customers.connect 'tag/create', :controller => 'Tag', :action => 'create'
  end

  map.resources :publications do |publications|
    publications.resources :issues, :member => {
        :show_packing_instructions => :get,
        :show_distribution_order => :get,
        :show_distribution_quote_request => :get,
        :show_distribution_list => :get,
        :show_special_order_lines => :get
    } do |issues|
      issues.resources :orders, :controller => 'IssueOrders', :member => {
        :set_order_num_copies => :post,
      }
      issues.resources :notes, :controller => 'IssueNotes'
    end
    publications.resources :standing_orders, :controller => 'PublicationStandingOrders'
    publications.resources :waiting_orders, :controller => 'PublicationWaitingOrders'
  end

  map.resources :issues_select, :collection => { :browse => :get }, :member => { :select => :post }

  map.resources :special_orders, :member => {
    :approve => :put,
    :deny => :put,
    :complete => :put
  } do |special_orders|
    special_orders.resources :notes, :controller => 'SpecialOrderNotes'
  end

  map.resource :help

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  map.connect '', :controller => "customers"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
