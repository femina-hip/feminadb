class CustomerWaitingOrdersController < ApplicationController
  require_role 'edit-orders'

  make_resourceful do
    actions :new, :create, :edit, :update, :destroy
    belongs_to :customer

    before :new do
      @waiting_order.request_date ||= Date.today
    end

    response_for(:create) do |format|
      format.html do
        set_default_flash(:notice, 'Waiting Order successfully created.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:update) do |format|
      format.html do
        set_default_flash(:notice, 'Waiting Order successfully updated.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:destroy) do |format|
      format.html do
        set_default_flash(:notice, 'Waiting Order successfully deleted.')
        set_default_redirect parent_path
      end
      format.js
    end
  end

  protected
    def current_model_name
      'WaitingOrder'
    end

    def instance_variable_name
      'waiting_orders'
    end
end
