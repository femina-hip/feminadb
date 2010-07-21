class IssuesController < ApplicationController
  require_role 'edit-issues', :except => [ :index, :show, :show_distribution_list, :show_distribution_quote_request, :show_packing_instructions, :show_distribution_order, :orders_in_district ]
  before_filter :get_publication
  cache_sweeper :nav_sweeper

  make_resourceful do
    actions :index, :show, :new, :edit, :destroy

    belongs_to(:publication)

    before(:new) do
      current_object.packing_hints = current_object.publication.packing_hints
    end
  end

  def create
    @issue = @publication.issues.build(params[:issue].merge(:updated_by => current_user))

    respond_to do |format|
      if @issue.save
        format.html { redirect_to([@issue.publication, @issue], :notice => 'Issue was successfully created.') }
        format.xml  { render(:xml => @issue, :status => :created, :location => @issue) }
      else
        format.html { render(:action => "new") }
        format.xml  { render(:xml => @issue.errors, :status => :unprocessable_entity) }
      end
    end
  end

  def update
    @issue = Issue.includes(:publication).find(params[:id])

    respond_to do |format|
      if @issue.update_attributes(params[:issue].merge(:updated_by => current_user))
        format.html { redirect_to([@issue.publication, @issue], :notice => 'Issue was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render(:action => 'edit') }
        format.xml { render(:xml => @issue.errors, :status => :unprocessable_entity) }
      end
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
      DeliveryMethod.where(:include_in_distribution_quote_request => true).active.order(:name).all
  end

  # GET /publications/1/issues/1/show_distribution_order
  def show_distribution_order
    # [req:ReportDistributionOrder]
    @issue = Issue.find(params[:id])

    @data = @issue.distribution_order_data

    @delivery_methods =
      DeliveryMethod.active.order(:name).all.select{|dm| @data.include?(dm)}
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
        send_data(writer.pdf.render, :filename => 'distribution_list.pdf', :type => 'application/pdf', :disposition => 'inline')
      end
      format.csv do
        send_data(@issue.distribution_list_csv(@delivery_method), :filename => 'distribution_list.csv', :type => 'text/csv', :disposition => 'inline')
      end
    end
  end

  def orders_in_district
    @issue = Issue.find(params[:id])
    @region = Region.find(params[:region_id])
    @district = params[:district]

    @orders = Order.where(:region_id => @region.id, :district => @district, :issue_id => @issue.id).order('num_copies DESC').all
  end

  def authorized_for_generate_orders?
    current_user.has_role?('edit-orders')
  end

  def destroy
    #load_object
    before :destroy
    if current_object.soft_delete(:updated_by => current_user)
      after :destroy
      response_for :destroy
    else
      after :destroy_fails
      response_for :destroy_fails
    end
  end

  protected

  def current_objects
    @current_objects ||= get_publication.issues
  end

  private

  def get_publication
    @publication ||= Publication.includes(:issues => :publication).find(params[:publication_id])
  end

  def object_parameters
    params[current_model_name.underscore] && params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
