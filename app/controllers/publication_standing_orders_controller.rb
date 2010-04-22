class PublicationStandingOrdersController < ApplicationController
  include CustomerFilterControllerMethods

  require_role 'edit-orders', :except => :index

  before_filter :load_publication

  # GET /publications/1/standing_orders
  # GET /publications/1/standing_orders.csv
  def index
    if params[:all]
      customers = search_for_customers(
        :order => [:delivery_method, :region, :district, :name],
        :includes => [:region, :delivery_method, :type]
      )

      orders_by_customer_id = {}
      @publication.standing_orders.where(:customer_id => customers.collect(&:id)).each do |o|
        orders_by_customer_id[o.customer_id] = o
      end

      @standing_orders = customers.dup # WillPaginate magic
      @standing_orders.replace(customers.collect { |c| orders_by_customer_id[c.id] || build_standing_order_for_customer(c) })
    else
      @standing_orders = @publication.standing_orders.includes(:customer => [:region, :delivery_method, :type]).order('delivery_methods.abbreviation, regions.name, customers.district, customers.name').where(conditions).paginate(:page => requested_page, :per_page => requested_per_page)
    end

    respond_to do |type|
      type.html do
        # index.haml
      end
      type.csv do
        render(:csv => @standing_orders)
      end
    end
  end

  def create
    @standing_order = @publication.standing_orders.build((params[:standing_order] || {}).merge(:updated_by => current_user))

    respond_to do |format|
      if @standing_order.save
        format.html { redirect_to(publication_standing_orders_path(@publication), :notice => 'Standing Order created') }
        format.js { render(:json => {}) }
      else
        format.html { render(:action => :new) }
        format.js { render(:json => @standing_order.errors, :status => 422) }
      end
    end
  end

  def update
    @standing_order = StandingOrder.find(params[:id])

    respond_to do |format|
      if @standing_order.update_attributes((params[:standing_order] || {}).merge(:updated_by => current_user))
        format.html { redirect_to(publication_standing_orders_path(@publication), :notice => 'Standing Order updated') }
        format.js { render(:json => {}) }
      else
        format.html { render(:action => :edit) }
        format.js { render(:json => @standing_order.errors, :status => 422) }
      end
    end
  end

  private

  def load_publication
    @publication = Publication.find(params[:publication_id])
  end

  def self.model_class
    StandingOrder
  end

  def build_standing_order_for_customer(customer)
    StandingOrder.new(
      :publication_id => @publication.id,
      :publication => @publication, # speed
      :customer_id => customer.id,
      :customer => customer # speed
    )
  end
end
