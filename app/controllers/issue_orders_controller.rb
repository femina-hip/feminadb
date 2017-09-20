class IssueOrdersController < ApplicationController
  include CustomerFilterControllerMethods

  respond_to(:html, :js)

  def index
    @issue = Issue.includes(:publication).find(params[:issue_id])

    @orders = if params[:all]
      issue_orders_for_customer_search(@issue)
    else
      issue_orders(@issue)
    end

    @search = search_result_facets

    respond_to do |format|
      format.html # index.haml
      format.csv do
        ActiveRecord::Associations::Preloader.new.preload(@orders, customer: :type)
        render(:csv => @orders)
      end
    end
  end

  private

  # Returns Orders for all matched Customers.
  #
  # If a Customer doesn't have an Order for this issue, returns a stub Order
  # for that Customer.
  def issue_orders_for_customer_search(issue)
    found_customer_ids = search_result_customer_ids
    WillPaginate::Collection.create(requested_page, requested_per_page, found_customer_ids.length) do |pager|
      shown_customer_ids = found_customer_ids[pager.offset, pager.per_page]
      # We'll find by these IDs, but they won't be in order -- we need to order
      # them ourselves.

      order_by_customer_id = issue.orders
        .where(customer_id: shown_customer_ids)
        .includes(customer: [ { region: :delivery_method }, :type ])
        .index_by(&:customer_id)

      customer_by_id = Customer.where(id: shown_customer_ids - order_by_customer_id.keys)
        .includes([ { region: :delivery_method }, :type ])
        .index_by(&:id)

      pager.replace(shown_customer_ids.map { |id| order_by_customer_id[id] || build_order_for_customer(customer_by_id[id]) })
    end
  end

  # Returns existing Orders for this Issue that match the Customer search.
  def issue_orders(issue)
    issue.orders
      .where(customer_id: search_result_customer_ids)
      .order(:delivery_method, :region, :council, :customer_name)
      .paginate(page: requested_page, per_page: requested_per_page)
  end

  def build_order_for_customer(customer)
    @issue.orders.build(
      customer_id: customer.id,
      delivery_method: customer.delivery_method.name,
      region: customer.region.name,
      council: customer.council,
      customer_name: customer.name,
      num_copies: 0,
      order_date: Date.today,
      delivery_address: customer.delivery_address,
      delivery_contact: customer.delivery_contact,
      primary_contact_sms_numbers: customer.primary_contact_sms_numbers,
      headmaster_sms_numbers: customer.headmaster_sms_numbers
    )
  end
end
