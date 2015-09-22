class CustomersController < ApplicationController
  include CustomerFilterControllerMethods

  def new
    require_role 'edit-customer'
    @customer = Customer.build
  end

  def edit
    require_role 'edit-customer'
    @customer = customer
  end

  def create
    require_role 'edit-customer'
    @customer = create_with_audit(Customer, customer_params)
    if @customer.valid?
      redirect_to(@customer)
    else
      render(action: 'new')
    end
  end

  def destroy
    require_role 'edit-customer'
    destroy_with_audit(customer)
    redirect_to(Customer)
  end

  def update
    require_role 'edit-customer'
    if update_with_audit(customer, customer_params)
      redirect_to(customer)
    else
      render(action: 'edit')
    end
  end

  def index
    @customers = search_for_customers(order: [:region, :district, :name], includes: [:region, :type, :club])

    @publications = Publication.tracking_standing_orders.order(:name).all

    respond_to do |type|
      type.html do
        ActiveRecord::Associations::Preloader.new.preload(@customers, [ :standing_orders, :waiting_orders ])
        # render index.haml
      end
      type.csv do
        ActiveRecord::Associations::Preloader.new.preload(@customers, [ :delivery_method ])
        render(:csv => @customers)
      end
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
    @customer = customer
  end

  def tag
    require_role 'edit-customers'
    tag_name = Tags.normalize_name(params[:tag][:name])
    note = create_with_audit!(customer.notes, note: "TAG_#{tag_name}")
    redirect_to(customer)
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
end
