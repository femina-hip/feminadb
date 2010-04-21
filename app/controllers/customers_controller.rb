class CustomersController < ApplicationController
  include ActsAsReportableControllerHelper
  require_role 'edit-customers', :except => [ :index, :show ]

  before_filter :remember_q_and_page, :only => :index

  make_resourceful do
    actions :new, :edit, :create, :update, :destroy
  end

  # GET /customers
  # GET /customers.csv
  # GET /customers.xml
  def index
    q = requested_q
    page = requested_page
    per_page = requested_per_page

    search = Customer.search do
      CustomersSearcher.apply_query_string_to_search(self, q)
      order_by :region
      order_by :district
      order_by :name
      paginate :page => page, :per_page => per_page
    end

    @customers = search.results
    Customer.send(:preload_associations, @customers, [:region, :type])
    @publications = Publication.active.tracking_standing_orders.order(:name).all

    respond_to do |type|
      type.html do
        Customer.send(:preload_associations, @customers, [:standing_orders, :waiting_orders])
        params[:q] = requested_q
        # render index.haml
      end
      type.csv do
        Customer.send(:preload_associations, @customers, [:delivery_method])
        render(:csv => @customers)
      end
      type.xml  { render(:xml => @customers.to_xml) }
    end
  end

  def similar
    customer = params[:customer]
    @raw_results = Customer.fuzzy_find(customer[:region_id].to_i, customer[:district], customer[:name])

    render(:json => @raw_results.collect { |r|
      {
        :id => r.primary_key.to_i,
        :region => r.stored(:region),
        :district => r.stored(:district),
        :name => r.stored(:name)
      }
    })
  end

  def show
    @customer = find_customer
  end

  def destroy
    before :destroy
    if current_object.soft_delete(:updated_by => current_user)
      after :destroy
      response_for :destroy
    else
      after :destroy_fails
      response_for :destroy_fails
    end
  end

  def tag
    customer = Customer.find(params[:id])

    tag_name = Tags.normalize_name(params[:tag][:name])

    note = customer.notes.build(:note => "TAG_#{tag_name}")

    respond_to do |format|
      if note.save
        flash[:notice] = "Tag #{tag_name} was successfully added."
        format.html { redirect_to customer_url(customer) }
        format.xml  { head :created, :location => customer_url(customer) }
      else
        flash[:notice] = "Tag #{tag_name} could not be added."
        format.html { redirect_to customer_url(customer) }
        format.xml  { head :created, :location => customer_url(customer) }
      end
    end
  end

  private

  def default_includes
    [ :region, :type, :delivery_method ]
  end

  def requested_page
    return params[:page].to_i if params[:page].to_i > 0
    return session[:customers_page] if not params[:q]
    1
  end

  def requested_per_page
    return :all if request.format == Mime::CSV
    Customer.per_page
  end

  def requested_q
    params[:q] || session[:customers_q] || ''
  end

  def remember_q_and_page
    session[:customers_q] = params[:q] if params[:q]
    session[:customers_page] = requested_page
  end

  def find_customer
    Customer.find(params[:id])
  end

  def object_parameters
    params[current_model_name.underscore] && params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
