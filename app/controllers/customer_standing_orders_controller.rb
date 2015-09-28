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
      redirect_to(customer)
    else
      render(action: 'new')
    end
  end

  def edit
    require_role 'edit-orders'
    @standing_order = standing_order
  end

  def update
    require_role 'edit-orders'
    if update_with_audit(standing_order, standing_order_update_params)
      customer.solr_index!
      redirect_to(customer)
    else
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
