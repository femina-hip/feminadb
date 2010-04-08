class IssueOrdersController < ApplicationController
  include ActsAsReportableControllerHelper

  require_role 'edit-orders', :except => [ :index ]
  before_filter :get_publication
  before_filter :get_issue

  in_place_edit_for :order, :num_copies

  # GET /publications/1/issues/1/orders
  # GET /publications/1/issues/1/orders.xml
  def index
    conditions = { :issue_id => @issue.id }
    if requested_q != ''
      q = requested_q
      lots = 999999
      all_ids = Customer.search_ids do
        CustomersSearcher.apply_query_string_to_search(q)
        paginate(:page => 1, :per_page => lots)
      end
      conditions[:customer_id] = Customer.includes(:orders).where('orders.issue_id' => @issue.id, :id => all_ids).collect(&:id)
    end

    @orders = Order.includes(requested_include).where(conditions).order('delivery_methods.name, regions.name, orders.district, orders.customer_name').paginate(:page => requested_page, :per_page => requested_per_page)

    respond_to do |format|
      format.html # index.haml
      format.xml  { render :xml => @orders.to_xml }
      format.csv do
        table = report_table_from_objects(
          @orders,
          :only => [ :num_copies, :order_date, :comments ],
          :include => {
            :region => { :only => :name },
            :delivery_method => { :only => [ :abbreviation, :name ] },
            :customer => {
              :only => [ :id, :name, :district, :deliver_via, :address, :po_box, :contact_name, :contact_position, :telephone_1, :telephone_2, :telephone_3, :fax, :email_1, :email_2, :website ],
              :include => {
                :type => { :only => [ :name, :description ] }
              }
            }
          },
          :order => [
            'delivery_method.abbreviation',
            'region.name',
            'district',
            'customer_name',
            'num_copies',
            'order_date',
            'comments',
            'customer.id',
            'customer.district',
            'customer.name',
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

  # DELETE /publications/1/issues/1/orders/1
  # DELETE /publications/1/issues/1/orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.update_attributes!(:deleted_at => Time.now, :updated_by => current_user)

    respond_to do |format|
      flash[:notice] = 'Order was successfully deleted.'
      format.html { redirect_to publication_issue_orders_path(@publication, @issue) }
      format.xml  { head :ok }
    end
  end

  private

  def get_publication
    @publication = Publication.find(params[:publication_id])
  end

  def get_issue
    @issue = Issue.find(params[:issue_id])
  end

  def requested_q
    params[:q] || ''
  end

  def requested_page
    (params[:page] || 1).to_i
  end

  def requested_per_page
    return :all if request.format == Mime::CSV
    Order.per_page
  end

  def requested_include
    return [ :region, :delivery_method, { :customer => :type } ] if request.format == Mime::CSV
    [ :region, :delivery_method ]
  end
end
