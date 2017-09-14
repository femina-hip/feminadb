class OrdersController < ApplicationController
  respond_to(:html, :js)

  def new
    require_role 'edit-orders'
    issue = Issue.find(params[:issue_id])
    customer = Customer.find(params[:customer_id])
    @order = build_order_for_issue_and_customer(issue, customer)
    render(layout: nil)
  end

  def edit
    require_role 'edit-orders'
    @order = Order.find(params[:id])
    render(layout: nil)
  end

  def create
    require_role 'edit-orders'
    order = create_with_audit(Order, order_params)
    if order.valid?
      respond_to do |format|
        format.html { redirect_to(edit_order_path(order)) }
        format.js { render(json: { text: order.num_copies.to_s, url: edit_order_path(order) }) }
      end
    else
      @order = order
      render(action: 'new', layout: nil)
    end
  end

  def update
    require_role 'edit-orders'
    order = Order.find(params[:id])
    json = if order_params[:num_copies].to_i > 0
      update_with_audit(order, order_params)
      {
        text: order.num_copies.to_s,
        url: edit_order_path(order)
      }
    else
      destroy_with_audit(order)
      {
        text: '…',
        url: new_order_path(issue_id: order.issue_id, customer_id: order.customer_id)
      }
    end
    if order.valid?
      respond_to do |format|
        format.html { redirect_to(json[:url]) }
        format.json { render(json: json) }
      end
    else
      @order = order
      render(action: 'edit', layout: nil)
    end
  end

  private

  def order_params
    params.require(:order).permit(
      :customer_id,
      :issue_id,
      :num_copies,
      :region,
      :council,
      :customer_name,
      :order_date,
      :delivery_method,
      :delivery_address,
      :delivery_contact,
      :comments
    )
  end

  def build_order_for_issue_and_customer(issue, customer)
    issue.orders.build(
      customer_id: customer.id,
      delivery_method: customer.delivery_method.name,
      region: customer.region.name,
      council: customer.council,
      customer_name: customer.name,
      num_copies: 0,
      order_date: Date.today,
      delivery_address: customer.delivery_address,
      delivery_contact: customer.delivery_contact
    )
  end
end
