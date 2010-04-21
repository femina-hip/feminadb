class PublicationWaitingOrdersController < ApplicationController
  include ActsAsReportableControllerHelper
  include CustomerFilterControllerMethods

  before_filter :load_publication

  # GET /publications/1/waiting_orders
  # GET /publications/1/waiting_orders.xml
  # GET /publications/1/waiting_orders.csv
  def index
    @waiting_orders = @publication.waiting_orders.includes(
      :customer => [ :region, :type ]
    ).order('customer_types.name, regions.name, customers.district, customers.name').where(conditions).paginate(
      :page => requested_page,
      :per_page => requested_per_page
    )

    respond_to do |format|
      format.html # index.haml
      format.xml  { render :xml => @waiting_orders.to_xml }
      format.csv do
        table = report_table_from_objects(
          @waiting_orders,
          :only => [ :num_copies, :request_date, :comments ],
          :include => {
            :customer => {
              :only => [ :id, :name, :district, :deliver_via, :address, :po_box, :contact_name, :contact_position, :telephone_1, :telephone_2, :telephone_3, :fax, :email_1, :email_2, :website ],
              :include => {
                :region => { :only => :name },
                :type => { :only => [ :name, :description ] }
              }
            }
          },
          :order => [
            'type.name',
            'region.name',
            'customer.district',
            'customer.name',
            'num_copies',
            'request_date',
            'comments',
            'comments',
            'customer.id',
            'customer.district',
            'customer.name',
            'type.description',
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

  def convert_to_standing_order
    waiting_order = WaitingOrder.find(params[:id])
    respond_to do |format|
      if waiting_order.convert_to_standing_order(:updated_by => current_user)
        format.html { redirect_to(publication_waiting_orders_path(@publication), :notice => 'Now it\'s a Standing Order') }
      else
        format.html { render(:action => 'index', :notice => 'Could not convert to a Standing Order') }
      end
    end
  end

  private

  def load_publication
    @publication = Publication.find(params[:publication_id])
  end

  def self.model_class
    WaitingOrder
  end
end
