class IssueOrdersController < ApplicationController
  include CustomerFilterControllerMethods

  require_role 'edit-orders', :except => [ :index ]

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
    @order = Order.find(params[:id])
    @order.soft_delete!(:updated_by => current_user)

    respond_to do |format|
      flash[:notice] = 'Order was successfully deleted.'
      format.html { redirect_to(params[:return_to] || publication_issue_orders_path(@publication, @issue)) }
      format.json { render_json_response }
      format.xml  { head :ok }
    end
  end

  def create
    @order = @issue.orders.build((params[:order] || {}).merge(:updated_by => current_user))

    respond_to do |format|
      if @order.save
        format.html { redirect_to(publication_issue_orders_path(@publication, @issue), :notice => "Order created") }
        format.js { render_json_response }
      else
        format.html { render(:action => :new) }
        format.js { render(:json => @order.errors, :status => 422) }
      end
    end
  end

  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes((params[:order] || {}).merge(:updated_by => current_user))
        format.html { redirect_to(publication_issue_orders_path(@publication, @issue), :notice => "Order updated") }
        format.js { render_json_response }
      else
        format.html { render(:action => :edit) }
        format.js { render_json_response }
      end
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

  def build_order_for_customer(customer)
    order = Order.new(
      :issue_id => @issue.id,
      :customer_id => customer.id,
      :customer => customer, # speed things up
      :region => customer.region,
      :delivery_method => customer.delivery_method
    )
    order.send(:copy_data_from_customer_if_new_record)
    order
  end
end
