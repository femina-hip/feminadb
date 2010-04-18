class PublicationStandingOrdersController < ApplicationController
  include ActsAsReportableControllerHelper

  require_role 'edit-orders', :except => :index

  before_filter :load_publication

  # GET /publications/1/standing_orders
  # GET /publications/1/standing_orders.csv
  def index
    conditions = {}
    if requested_q != ''
      q = requested_q
      lots = 999999
      all_ids = Customer.search_ids do
        CustomersSearcher.apply_query_string_to_search(self, q)
        paginate(:page => 1, :per_page => lots)
      end
      conditions[:customer_id] = all_ids
    end

    @standing_orders = @publication.standing_orders.includes(:customer => [:region, :delivery_method, :type]).order('delivery_methods.abbreviation, regions.name, customers.district, customers.name').where(conditions).paginate(:page => requested_page, :per_page => requested_per_page)

    respond_to do |type|
      type.html do
        # index.haml
      end
      type.csv do
        table = report_table_from_objects(
          @standing_orders,
          :only => [ :num_copies ],
          :include => {
            :customer => {
              :only => [ :id, :name, :district, :deliver_via, :address, :po_box, :contact_name, :contact_position, :telephone_1, :telephone_2, :telephone_3, :fax, :email_1, :email_2, :website ],
              :include => {
                :region => { :only => :name },
                :delivery_method => { :only => [ :abbreviation, :name ] },
                :type => { :only => [ :name, :description ] }
              }
            }
          },
          :order => [
            'delivery_method.abbreviation',
            'region.name',
            'customer.district',
            'customer.name',
            'num_copies',
            'customer.id',
            'type.name',
            'type.description',
            'delivery_method.name',
            'customer.deliver_via',
            'customer.address',
            'customer.po_box',
            'customer.contact_name',
            'customer.contact_position',
            'customer.telephone_1',
            'customer.telephone_2',
            'customer.telephone_3',
            'customer.fax',
            'customer.email_1',
            'customer.email_2',
            'customer.website'
          ]
        )
        s = table.as(:csv)
        render :text => s
      end
    end
  end

  private

  def load_publication
    @publication = Publication.find(params[:publication_id])
  end

  def requested_page
    return params[:page].to_i if params[:page].to_i > 0
    1
  end

  def requested_per_page
    return 2**30 if request.format == Mime::CSV
    StandingOrder.per_page
  end

  def requested_q
    params[:q] || ''
  end
end
