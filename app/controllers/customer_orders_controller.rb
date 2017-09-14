class CustomerOrdersController < ApplicationController
  def new
    require_role 'edit-orders'
    @order = customer.orders.build(
      customer_name: customer.name,
      delivery_method: customer.delivery_method.name,
      delivery_address: customer.delivery_address,
      delivery_contact: customer.delivery_contact,
      region: customer.region.name,
      council: customer.council,
      order_date: Date.today
    )
    render(layout: nil)
  end

  def create
    require_role 'edit-orders'
    @order = create_with_audit(customer.orders, order_params)
    if @order.valid?
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: {
          tr_html: render_to_string(partial: 'tr', locals: { order: @order }, formats: [ :html ])
        }) }
      end
    else
      render(action: 'new')
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
      :council,
      :customer_name,
      :delivery_method,
      :delivery_address,
      :delivery_contact
    )
  end
end
