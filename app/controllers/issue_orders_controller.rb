class IssueOrdersController < ApplicationController
  include ActsAsReportableControllerHelper
  include CustomerFilterControllerMethods

  require_role 'edit-orders', :except => [ :index ]
  before_filter :get_publication
  before_filter :get_issue

  # GET /publications/1/issues/1/orders
  # GET /publications/1/issues/1/orders.xml
  def index
    @orders = @issue.orders.includes(:region, :delivery_method).where(conditions).order('delivery_methods.name, regions.name, orders.district, orders.customer_name').paginate(:page => requested_page, :per_page => requested_per_page)

    respond_to do |format|
      format.html # index.haml
      format.xml  { render :xml => @orders.to_xml }
      format.csv do
        Order.send(:preload_associations, @orders, :customer => :type)
        render(:csv => @orders)
      end
    end
  end

  # DELETE /publications/1/issues/1/orders/1
  # DELETE /publications/1/issues/1/orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.soft_delete!(:updated_by => current_user)

    respond_to do |format|
      flash[:notice] = 'Order was successfully deleted.'
      format.html { redirect_to publication_issue_orders_path(@publication, @issue) }
      format.xml  { head :ok }
    end
  end

  private

  def get_publication
    @publication = get_issue.publication
  end

  def get_issue
    @issue = Issue.includes(:publication).find(params[:issue_id])
  end

  def self.model_class
    Order
  end

  def requested_include
    return [ :region, :delivery_method, { :customer => :type } ] if request.format == Mime::CSV
    [ :region, :delivery_method ]
  end
end
