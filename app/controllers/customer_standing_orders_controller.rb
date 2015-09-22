class CustomerStandingOrdersController < ApplicationController
  make_resourceful do
    actions :new, :create, :edit, :update, :destroy
    belongs_to :customer

    before(:new, :create, :edit, :update, :destroy) do
      require_role 'edit-orders'
    end

    response_for(:create) do |format|
      format.html do
        set_default_flash(:notice, 'Standing Order successfully created.')
        set_default_redirect(customer_path(current_object.customer))
      end
      format.js
    end

    response_for(:update) do |format|
      format.html do
        set_default_flash(:notice, 'Standing Order successfully updated.')
        set_default_redirect(customer_path(current_object.customer))
      end
      format.js
    end

    response_for(:destroy) do |format|
      format.html do
        set_default_flash(:notice, 'Standing Order successfully deleted.')
        set_default_redirect(customer_path(current_object.customer))
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
    'StandingOrder'
  end

  def instance_variable_name
    'standing_orders'
  end

  def object_parameters
    params[current_model_name.underscore] && params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
