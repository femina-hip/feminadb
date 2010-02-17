class CustomerStandingOrdersController < ApplicationController
  require_role 'edit-orders'

  make_resourceful do
    actions :new, :create, :edit, :update, :destroy
    belongs_to :customer

    response_for(:create) do |format|
      format.html do
        set_default_flash(:notice, 'Standing Order successfully created.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:update) do |format|
      format.html do
        set_default_flash(:notice, 'Standing Order successfully updated.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:destroy) do |format|
      format.html do
        set_default_flash(:notice, 'Standing Order successfully deleted.')
        set_default_redirect parent_path
      end
      format.js
    end
  end

  protected
    def current_model_name
      'StandingOrder'
    end

    def instance_variable_name
      'standing_orders'
    end
end
