class IssuesController < ApplicationController
  def index
    @publication = publication
    @issues = if @publication
      @publication.issues
    else
      Issue.includes(:publication).order(issue_date: :desc)
    end
  end

  def show
    @issue = issue
    @publication = issue.publication
  end

  def new
    require_role 'edit-issues'
    @issue = publication.issues.build
  end

  def edit
    require_role 'edit-issues'
    @issue = issue
  end

  def destroy
    require_role 'edit-issues'
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
    if update_with_audit(issue, issue_params)
      redirect_to(@issue)
    else
      render(action: 'edit')
    end
  end

  def show_distribution_order
    # [req:ReportDistributionOrder]
    @issue = issue
    @data = @issue.distribution_order_data
  end

  def show_num_copies_by_council
    send_data(issue.num_copies_by_council_csv, type: 'text/csv')
  end

  def show_distribution_list
    # [req:ReportDistributionList]
    @issue = issue
    if params[:delivery_method]
      delivery_method_object = DeliveryMethod.find_by_name(params[:delivery_method].to_s)
      if delivery_method_object.nil?
        return render(status: 404, text: 'Delivery method not found')
      end
      @delivery_method = delivery_method_object.name
    end

    respond_to do |format|
      format.html do
        @data = @issue.distribution_list_data(@delivery_method)
      end
      format.csv do
        send_data(@issue.distribution_list_csv(@delivery_method), :filename => 'distribution_list.csv', :type => 'text/csv', :disposition => 'inline')
      end
    end
  end

  def authorized_for_generate_orders?
    current_user.has_role?('edit-orders')
  end

  private

  def publication
    @publication ||= if params[:publication_id]
      Publication.find(params[:publication_id])
    else
      nil
    end
  end

  def issue
    @issue ||= Issue.includes(:publication).find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(
      :name,
      :issue_date,
      :issue_number,
      :box_sizes
    )
  end
end
