class CustomersController < ApplicationController
  include CustomerFilterControllerMethods

  def new
    require_role 'edit-customers'
    @customer = Customer.new
  end

  def edit
    require_role 'edit-customers'
    @customer = customer
  end

  def create
    require_role 'edit-customers'
    @customer = create_with_audit(Customer, customer_params)
    if @customer.valid?
      @customer.solr_index!
      redirect_to(@customer)
    else
      render(action: 'new')
    end
  end

  def destroy
    require_role 'edit-customers'
    Order.where(customer_id: customer.id).update_all(customer_id: nil)
    StandingOrder.where(customer_id: customer.id).delete_all
    WaitingOrder.where(customer_id: customer.id).delete_all
    CustomerNote.where(customer_id: customer.id).delete_all
    destroy_with_audit(customer)
    customer.solr_remove_from_index!
    redirect_to(Customer)
  end

  def update
    require_role 'edit-customers'
    if update_with_audit(customer, customer_params)
      customer.solr_index!
      redirect_to(customer)
    else
      render(action: 'edit')
    end
  end

  def add_sms_number
    require_role 'edit-customers'

    # If the number was in the trash can, take it out
    if params[:attribute] != 'old_sms_numbers'
      customer.remove_sms_number('old_sms_numbers', params[:sms_number])
    end

    customer.add_sms_number(params[:attribute], params[:sms_number])

    save_with_audit!(customer)
    customer.solr_index!
    render('_editable_sms_number', layout: nil, locals: {
      customer: customer, attribute: params[:attribute], sms_number: params[:sms_number]
    })
  end

  def remove_sms_number
    require_role 'edit-customers'

    customer.remove_sms_number(params[:attribute], params[:sms_number])

    if params[:attribute] != 'old_sms_numbers'
      # old_sms_numbers is special: it's like a trash can. Delete moves things
      # there.
      customer.add_sms_number('old_sms_numbers', params[:sms_number])
    end

    save_with_audit!(customer)
    customer.solr_index!
    redirect_to(customer)
  end

  def index
    @customers = search_for_customers(order: [:region, :district, :name], includes: [:region, :type ])

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

  def autocomplete
    q = params[:q].to_s
    q += '*' if q.present?
    customers = customer_search(q: q, order: [:region, :district, :name], page: 1, per_page: 10).results
    ActiveRecord::Associations::Preloader.new.preload(customers, [ :region, :type ])

    json = customers.map do |customer|
      {
        id: customer.id,
        name: customer.name,
        region: customer.region.name,
        district: customer.district,
        type: {
          name: customer.type.name,
          description: customer.type.description
        }
      }
    end

    render(json: json)
  end

  def show
    @customer = customer

    ActiveRecord::Associations::Preloader.new.preload(@customer.standing_orders, :publication)
    ActiveRecord::Associations::Preloader.new.preload(@customer.waiting_orders, :publication)
    ActiveRecord::Associations::Preloader.new.preload(@customer.orders, issue: :publication)
  end

  private

  def customer
    @customer ||= Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :name,
      :customer_type_id,
      :delivery_method_id,
      :region_id,
      :district,
      :delivery_address,
      :delivery_contact
    )
  end
end
