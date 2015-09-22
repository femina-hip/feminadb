class CustomersController < ApplicationController
  include CustomerFilterControllerMethods

  make_resourceful do
    actions :new, :edit, :create, :destroy
  end

  def update
    require_role 'edit-customer'
    update_with_audit!(customer, customer_params)
    redirect_to(customer)
  end

  # GET /customers
  # GET /customers.csv
  # GET /customers.xml
  def index
    @customers = search_for_customers(:default_order => [:region, :district, :name], :includes => [:region, :type, :club])

    @publications = Publication.active.tracking_standing_orders.order(:name).all

    respond_to do |type|
      type.html do
        ActiveRecord::Associations::Preloader.new.preload(@customers, [ :standing_orders, :waiting_orders ])
        # render index.haml
      end
      type.csv do
        ActiveRecord::Associations::Preloader.new.preload(@customers, [ :delivery_method ])
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
    @customer = Customer.find(params[:id])
  end

  def destroy
    require_role 'edit-customers'
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
    require_role 'edit-customers'
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

  def customer
    @customer ||= Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :name,
      :customer_type_id,
      :region_id,
      :district,
      :delivery_method_id,
      :deliver_via,
      :route,
      :address,
      :po_box,
      :contact_name,
      :contact_position,
      :telephone_1,
      :telephone_2,
      :telephone_3,
      :fax,
      :email_1,
      :email_2,
      :website
    )
  end

  def self.model_class
    Customer
  end

  def object_parameters
    params[current_model_name.underscore] && params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
