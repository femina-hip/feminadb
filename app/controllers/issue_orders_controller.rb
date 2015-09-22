class IssueOrdersController < ApplicationController
  include CustomerFilterControllerMethods

  respond_to(:html, :js)

  before_filter :get_publication
  before_filter :get_issue

  # GET /publications/1/issues/1/orders
  # GET /publications/1/issues/1/orders.xml
  def index
    if params[:all]
      customers = search_for_customers(
        :order => [:delivery_method, :region, :district, :name],
        :includes => [:region, :type, :delivery_method]
      )

      orders_by_customer_id = {}
      @issue.orders.where(:customer_id => customers.collect(&:id)).each do |o|
        orders_by_customer_id[o.customer_id] = o
      end

      @orders = customers.dup # WillPaginate magic
      @orders.replace(customers.collect { |c| orders_by_customer_id[c.id] || build_order_for_customer(c) })
    else
      @orders = @issue.orders.includes(:region, :delivery_method, :issue => :publication).where(conditions).order('delivery_methods.abbreviation, regions.name, orders.district, orders.customer_name').paginate(:page => requested_page, :per_page => requested_per_page)
    end

    respond_to do |format|
      format.html # index.haml
      format.xml  { render :xml => @orders.to_xml }
      format.csv do
        Order.send(:preload_associations, @orders, :customer => :type)
        render(:csv => @orders)
      end
    end
  end

  # DELETE /publications/1/issues/1/orders/1
  # DELETE /publications/1/issues/1/orders/1.xml
  def destroy
    require_role 'edit-orders'
    @order = Order.find(params[:id])
    flash[:notice] = 'Order destroyed' if @order.soft_delete(:updated_by => current_user)
    respond_with(@order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  def create
    require_role 'edit-orders'
    @order = @issue.orders.build(order_param)
    flash[:notice] = 'Order created' if @order.save
    respond_with(@order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  def update
    require_role 'edit-orders'
    @order = Order.find(params[:id])
    flash[:notice] = 'Order updated' if @order.update_attributes(order_param)
    respond_with(@order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  private

  def render_json_response
    render(:json => {
      'td_html' => render_to_string(:partial => 'qty.html', :locals => {
        :order => @order.deleted_at.nil? ? @order : build_order_for_customer(@order.customer)
      })
    })
  end

  def get_publication
    @publication = get_issue.publication
  end

  def get_issue
    @issue = Issue.includes(:publication).find(params[:issue_id])
  end

  def self.model_class
    Order
  end

  def order_param
    (params[:order] || {}).merge(:updated_by => current_user)
  end

  def build_order_for_customer(customer)
    order = Order.new(
      :issue_id => @issue.id,
      :issue => @issue, # speed things up
      :customer_id => customer.id,
      :customer => customer, # speed things up
      :region => customer.region,
      :delivery_method => customer.delivery_method
    )
    order.send(:copy_data_from_customer_if_new_record)
    order
  end

  def redirect_location
    params[:return_to] || [@publication, @issue, :orders]
  end
end
