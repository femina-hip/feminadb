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

  def destroy
    #load_object
    before :destroy
    if current_object.soft_delete(:updated_by => current_user)
      after :destroy
      response_for :destroy
    else
      after :destroy_fails
      response_for :destroy_fails
    end
  end

  protected

  def current_model_name
    'Order'
  end

  def instance_variable_name
    'orders'
  end

  def object_parameters
    params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
