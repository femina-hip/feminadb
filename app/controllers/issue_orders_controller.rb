class IssueOrdersController < ApplicationController
  include CustomerFilterControllerMethods

  respond_to(:html, :js)

  def index
    @issue = issue

    if params[:all]
      customers = search_for_customers(
        :order => [ :region, :council, :name ],
        :includes => [ { region: :delivery_method }, :type ]
      )

      orders_by_customer_id = {}
      @issue.orders.where(:customer_id => customers.collect(&:id)).each do |o|
        orders_by_customer_id[o.customer_id] = o
      end

      @orders = customers.dup # WillPaginate magic
      @orders.replace(customers.collect { |c| orders_by_customer_id[c.id] || build_order_for_customer(c) })
    else
      @orders = @issue.orders
        .where(conditions)
        .order(:delivery_method, :region, :council, :customer_name)
        .paginate(:page => requested_page, :per_page => requested_per_page)
    end

    respond_to do |format|
      format.html # index.haml
      format.csv do
        ActiveRecord::Associations::Preloader.new.preload(@orders, customer: :type)
        render(:csv => @orders)
      end
    end
  end

  def destroy
    require_role 'edit-orders'
    destroy_with_audit(order)
    respond_to do |format|
      format.html { redirect_to([ issue, :orders ]) }
      format.js { render_json_response }
    end
  end

  def create
    require_role 'edit-orders'
    order = create_with_audit(@issue.orders, order_params)
    if order.valid?
      respond_to do |format|
        format.html { redirect_to([ issue, :orders ]) }
        format.js { render_json_response }
      end
    else
      raise Exception, 'invalid create parameters'
    end
  end

  def update
    require_role 'edit-orders'
    if update_with_audit(order, order_params)
      respond_to do |format|
        format.html { redirect_to([ issue, :orders ]) }
        format.js { render_json_response }
      end
    else
      raise Exception, 'invalid update parameters'
    end
  end

  private

  def render_json_response
    render(:json => {
      'td_html' => render_to_string(:partial => 'qty.html', :locals => { :order => @order })
    })
  end

  def issue
    @issue ||= Issue.includes(:publication).find(params[:issue_id])
  end

  def order_params
    params.require(:order).permit(
      :customer_id,
      :num_copies,
      :region,
      :council,
      :customer_name,
      :delivery_method,
      :delivery_address,
      :delivery_contact,
      :comments
    )
  end

  def build_order_for_customer(customer)
    issue.orders.build(
      customer_id: customer.id,
      delivery_method: customer.delivery_method.name,
      region: customer.region.name,
      council: customer.council,
      customer_name: customer.name,
      num_copies: 0,
      delivery_address: customer.delivery_address,
      delivery_contact: customer.delivery_contact
    )
  end
end
