class CustomerOrdersController < ApplicationController
  def new
    require_role 'edit-orders'
    @customer = customer
    @order = customer.orders.build(order_date: Date.today)
  end

  def create
    require_role 'edit-orders'
    @order = create_with_audit(customer.orders, order_params)
    if @order.valid?
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: { text: @order.num_copies.to_s }) }
      end
    else
      render(action: 'new')
    end
  end

  def edit
    require_role 'edit-orders'
    @customer = customer
    @order = order
  end

  def update
    require_role 'edit-orders'
    if update_with_audit(order, order_params)
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: { text: order.num_copies.to_s }) }
      end
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
    if params[:id]
      @customer = order.customer
    else
      @customer ||= Customer.find(params[:customer_id])
    end
  end

  def order
    @order ||= Order.includes(:customer).find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :issue_id,
      :num_copies,
      :comments,
      :order_date,
      :region,
      :district,
      :customer_name,
      :delivery_method,
      :delivery_address,
      :delivery_contact
    )
  end
end
