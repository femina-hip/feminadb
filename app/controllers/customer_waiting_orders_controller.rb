class CustomerWaitingOrdersController < ApplicationController
  def new
    require_role 'edit-orders'
    @customer = customer
    @waiting_order = customer.waiting_orders.build(request_date: Date.today)
  end

  def create
    require_role 'edit-orders'
    @waiting_order = create_with_audit(customer.waiting_orders, waiting_order_create_params)
    if @waiting_order.valid?
      customer.solr_index!
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: { text: "#{@waiting_order.num_copies}W" }) }
      end
    else
      @customer = customer
      render(action: 'new')
    end
  end

  def edit
    require_role 'edit-orders'
    @customer = customer
    @waiting_order = waiting_order
  end

  def update
    require_role 'edit-orders'
    if update_with_audit(waiting_order, waiting_order_update_params)
      customer.solr_index!
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: { text: "#{@waiting_order.num_copies}W" }) }
      end
    else
      @customer = customer
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'edit-orders'
    destroy_with_audit(waiting_order)
    customer.solr_index!
    redirect_to(customer)
  end

  def convert_to_standing_order
    require_role 'edit-orders'
    standing_order = create_with_audit(customer.standing_orders, waiting_order.standing_order_create_params)
    if standing_order.valid?
      destroy_with_audit(waiting_order)
      customer.solr_index!
      redirect_to(customer)
    else
      redirect_to(customer, notice: 'Could not convert to a Standing Order. Ask an administrator to review the server logs.')
    end
  end

  protected

  def customer
    @customer ||= Customer.find(params[:customer_id])
  end

  def waiting_order
    @waiting_order ||= WaitingOrder.find(params[:id])
  end

  def waiting_order_create_params
    params.require(:waiting_order).permit(
      :customer_id,
      :publication_id,
      :num_copies,
      :comments,
      :request_date
    )
  end

  def waiting_order_update_params
    params.require(:waiting_order).permit(:num_copies, :comments, :request_date)
  end
end
