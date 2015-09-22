class CustomerOrdersController < ApplicationController
  def new
    require_role 'edit-orders'
    @customer = customer
    @order = customer.orders.build(order_date: Date.today)
  end

  def create
    require_role 'edit-orders'
    @order = create_with_audit(customer.orders, order_create_params)
    if @order.valid?
      redirect_to(customer)
    else
      render(action: 'new')
    end
  end

  def edit
    require_role 'edit-orders'
    @order = order
  end

  def update
    require_role 'edit-orders'
    if update_with_audit(order, order_update_params)
      redirect_to(customer)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'edit-orders'
    destroy_with_audit(order)
    redirect_to(customer)
  end

  protected

  def customer
    @customer ||= Customer.find(params[:customer_id])
  end

  def order
    @order ||= Order.find(params[:order_id])
  end

  def order_create_params
    params.require(:order).permit(
      :customer_id,
      :issue_id,
      :num_copies,
      :comments,
      :order_date,
      :region_id,
      :district,
      :customer_name,
      :deliver_via,
      :delivery_method_id,
      :contact_name,
      :contact_details
    )
  end

  def order_update_params
    params.require(:order).permit(
      :issue_id,
      :num_copies,
      :comments,
      :order_date,
      :region_id,
      :district,
      :customer_name,
      :deliver_via,
      :delivery_method_id,
      :contact_name,
      :contact_details
    )
  end
end
