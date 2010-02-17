class CustomerOrdersController < ApplicationController
  require_role 'edit-orders', :except => [ :index ]

  make_resourceful do
    actions :new, :create, :edit, :update, :destroy
    belongs_to :customer

    before :new do
      @order.order_date ||= Date.today
    end

    response_for(:create) do |format|
      format.html do
        set_default_flash(:notice, 'Order successfully created.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:update) do |format|
      format.html do
        set_default_flash(:notice, 'Order successfully updated.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:destroy) do |format|
      format.html do
        set_default_flash(:notice, 'Order successfully deleted.')
        set_default_redirect parent_path
      end
      format.js
    end
  end

  protected
    def current_model_name
      'Order'
    end

    def instance_variable_name
      'orders'
    end
end
