class CustomerStandingOrdersController < ApplicationController
  def new
    require_role 'edit-orders'
    @standing_order = customer.standing_orders.build
  end

  def create
    require_role 'edit-orders'
    @standing_order = create_with_audit(customer.standing_orders, standing_order_create_params)
    if @standing_order.valid?
      customer.solr_index!
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: {
          text: @standing_order.num_copies.to_s,
          url: edit_customer_standing_order_path(customer, @standing_order)
        }) }
      end
    else
      @customer = customer
      render(action: 'new')
    end
  end

  def edit
    require_role 'edit-orders'
    @customer = customer
    @standing_order = standing_order
  end

  def update
    require_role 'edit-orders'
    success, text, next_edit_url = if standing_order_update_params[:num_copies].to_i > 0
      [
        update_with_audit(standing_order, standing_order_update_params),
        standing_order_update_params[:num_copies],
        edit_customer_standing_order_path(customer, standing_order)
      ]
    else
      [
        destroy_with_audit(standing_order),
        '…',
        new_customer_standing_order_path(customer)
      ]
    end

    if success
      customer.solr_index!
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: { text: text, url: next_edit_url }) }
      end
    else
      @customer = customer
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'edit-orders'
    destroy_with_audit(standing_order)
    customer.solr_index!
    redirect_to(customer)
  end

  protected

  def customer
    @customer ||= Customer.find(params[:customer_id])
  end

  def standing_order
    @standing_order ||= StandingOrder.find(params[:id])
  end

  def standing_order_create_params
    params.require(:standing_order).permit(
      :customer_id,
      :publication_id,
      :num_copies,
      :comments
    )
  end

  def standing_order_update_params
    params.require(:standing_order).permit(:num_copies, :comments)
  end
end
