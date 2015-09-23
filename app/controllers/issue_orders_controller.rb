class IssueOrdersController < ApplicationController
  include CustomerFilterControllerMethods

  respond_to(:html, :js)

  def index
    @issue = issue

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
    order = create_with_audit(@issue.orders, order_create_params)
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
    if update_with_audit(order, order_update_params)
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
      'td_html' => render_to_string(:partial => 'qty.html', :locals => {
        :order => @order.deleted_at.nil? ? @order : build_order_for_customer(@order.customer)
      })
    })
  end

  def issue
    @issue ||= Issue.includes(:publication).find(params[:issue_id])
  end

  def order_create_params
    params.require(:order).permit(
      :issue_id,
      :customer_id,
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
end
