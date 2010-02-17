class PublicationStandingOrdersController < ApplicationController
  include CustomersQueryRewriter
  include ActsAsReportableControllerHelper

  require_role 'edit-orders', :except => :index

  before_filter :load_publication

  in_place_edit_for :standing_order, :num_copies

  # GET /publications/1/standing_orders
  # GET /publications/1/standing_orders.csv
  def index
    conditions = {}
    if customers_query(requested_q) != '*'
      customers = Customer.find_by_contents(
        customers_query(requested_q),
        {},
        :include => [ :standing_orders ],
        :conditions => [ 'standing_orders.publication_id = ?', @publication.id ]
      )
      conditions[:customer_id] = customers.collect{|c| c.id}
    end

    @standing_orders = StandingOrder.paginate_by_publication_id(
      @publication.id,
      :order => 'delivery_methods.abbreviation, regions.name, customers.district, customers.name',
      :include => { :customer => [ :region, :delivery_method, :type ] },
      :conditions => conditions,
      :page => requested_page,
      :per_page => requested_per_page
    )

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
