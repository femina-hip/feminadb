class IssuesController < ApplicationController
  require_role 'edit-issues', :except => [ :index, :show, :show_distribution_list, :show_distribution_quote_request, :show_packing_instructions, :show_special_order_lines, :show_distribution_order, :orders_in_district ]
  before_filter :get_publication

  make_resourceful do
    actions :index, :show, :new, :create, :edit, :update, :destroy

    belongs_to :publication

    before(:show) do
      @warehouses = Warehouse.find_all_inventory(:order => :name)
    end
  end

  # GET /publications/1/issues/1/show_packing_instructions
  def show_packing_instructions
    # [req:ReportPackingInstructions]
    @issue = Issue.find(params[:id])

    @packing_instructions_data = begin
      @issue.packing_instructions_data
    rescue Issue::DoesNotFitInBoxesException
      nil
    end
  end

  # GET /publications/1/issues/1/show_distribution_quote_request
  def show_distribution_quote_request
    # [req:ReportDistributionQuoteRequest]
    @issue = Issue.find(params[:id])

    @data = @issue.distribution_quote_request_data

    @delivery_methods =
      DeliveryMethod.where(:include_in_distribution_quote_request => true).where(:deleted_at => nil).order(:name).all
  end

  # GET /publications/1/issues/1/show_distribution_order
  def show_distribution_order
    # [req:ReportDistributionOrder]
    @issue = Issue.find(params[:id])

    @data = @issue.distribution_order_data

    @delivery_methods =
      DeliveryMethod.where(:deleted_at => nil).order(:name).all.select{|dm| @data.include?(dm)}
  end

  # GET /publications/1/issues/1/show_distribution_list
  def show_distribution_list
    # [req:ReportDistributionList]
    @issue = Issue.find(params[:id])

    @delivery_method = DeliveryMethod.find(params[:delivery_method_id]) if params[:delivery_method_id]

    respond_to do |format|
      format.html do
        @data = begin
          @issue.distribution_list_data(@delivery_method)
        rescue Issue::DoesNotFitInBoxesException
          nil
        end
      end
      format.pdf do
        writer = DistributionListPdfWriter.new(@issue, @delivery_method)
        send_data writer.pdf.render, :filename => 'distribution_list.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end

  # GET /publications/1/issues/1/show_special_order_lines
  def show_special_order_lines
    @issue = Issue.find(params[:id])

    @special_order_lines = SpecialOrderLine.find_all_by_issue_id(
      @issue.id,
      :include => { :special_order => :requested_by_user },
      :order => 'special_orders.requested_at DESC'
    )
  end

  def orders_in_district
    @issue = Issue.find(params[:id])
    @region = Region.find(params[:region_id])
    @district = params[:district]

    @orders = Order.where(:region_id => @region.id, :district => @district, :issue_id => @issue.id).order('num_copies DESC').all
  end

  def authorized_for_generate_orders?
    current_user.has_role?('admin')
  end

  def destroy
    #load_object
    before :destroy
    if current_object.update_attributes(:deleted_at => Time.now, :updated_by => current_user)
      after :destroy
      response_for :destroy
    else
      after :destroy_fails
      response_for :destroy_fails
    end
  end

  protected
    def current_objects
      @current_objects ||= Issue.find_all_by_publication_id(
        params[:publication_id],
        :order => 'issue_number DESC'
      )
    end

  private
    def get_publication
      @publication = Publication.find(params[:publication_id])
    end
end
