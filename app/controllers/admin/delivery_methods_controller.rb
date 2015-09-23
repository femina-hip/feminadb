class Admin::DeliveryMethodsController < ApplicationController
  def index
    @delivery_methods = DeliveryMethod.order(:abbreviation)
  end

  def new
    require_role 'admin'
    @delivery_method = DeliveryMethod.new
  end

  def edit
    require_role 'admin'
    @delivery_method = delivery_method
  end

  def create
    require_role 'admin'
    @delivery_method = create_with_audit(DeliveryMethod, delivery_method_params)
    if @delivery_method.valid?
      redirect_to(admin_delivery_methods_url)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'admin'
    if update_with_audit(delivery_method, delivery_method_params)
      redirect_to(admin_delivery_methods_url)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'admin'

    if delivery_method.customers.length > 0
      flash[:notice] = 'DeliveryMethod cannot be deleted because it has Customers'
    elsif delivery_method.orders.length > 0
      flash[:notice] = 'DeliveryMethod cannot be deleted because it has Orders'
    else
      destroy_with_audit(delivery_method)
    end
    redirect_to(admin_delivery_methods_url)
  end

  protected

  def delivery_method
    @delivery_method ||= DeliveryMethod.find(params[:id])
  end

  def delivery_method_params
    params.require(:delivery_method).permit(:warehouse_id, :name, :description, :abbreviation, :include_in_distribution_quote_request)
  end
end
