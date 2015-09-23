class IssuesController < ApplicationController
  def index
    @issues = publication.issues
  end

  def show
    @issue = issue
    @publication = issue.publication
  end

  def new
    require_role 'edit-issues'
    @issue = publication.issues.build(packing_hints: publication.packing_hints)
  end

  def edit
    require_role 'edit-issues'
    @issue = issue
  end

  def destroy
    require_role 'edit-issues'
    IssueBoxSize.where(issue_id: issue.id).delete_all
    IssueNote.where(issue_id: issue.id).delete_all
    Order.where(issue_id: issue.id).delete_all
    destroy_with_audit(issue)
    redirect_to(issue.publication)
  end

  def create
    require_role 'edit-issues'
    @issue = create_with_audit(publication.issues, issue_params)
    if @issue.valid?
      redirect_to(@issue)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'edit-issues'
    @issue = update_with_attributes(issue, issue_params)
    if @issue.valid?
      redirect_to(@issue)
    else
      render(action: 'edit')
    end
  end

  def show_packing_instructions
    # [req:ReportPackingInstructions]
    @issue = issue

    @packing_instructions_data = begin
      @issue.packing_instructions_data
    rescue Issue::DoesNotFitInBoxesException
      nil
    end
  end

  def show_distribution_quote_request
    # [req:ReportDistributionQuoteRequest]
    @issue = issue
    @data = @issue.distribution_quote_request_data

    @delivery_methods =
      DeliveryMethod.where(:include_in_distribution_quote_request => true).order(:name).all
  end

  def show_distribution_order
    # [req:ReportDistributionOrder]
    @issue = issue
    @data = @issue.distribution_order_data

    @delivery_methods =
      DeliveryMethod.order(:name).all.select{|dm| @data.include?(dm)}
  end

  # GET /publications/1/issues/1/show_distribution_list
  def show_distribution_list
    # [req:ReportDistributionList]
    @issue = issue
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

  private

  def publication
    @publication ||= Publication.includes(issues: :publication).find(params[:publication_id])
  end

  def issue
    @issue ||= Issue.includes(:publication).find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(
      :name,
      :issue_date_string,
      :issue_number,
      :issue_box_sizes_string,
      :quantity,
      :price,
      :packing_hints
    )
  end
end
