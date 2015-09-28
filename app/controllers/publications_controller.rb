class PublicationsController < ApplicationController
  def index
    @publications = Publication.order(:name).all
  end

  def new
    require_role 'edit-publications'
    @publication = Publication.new
  end

  def edit
    require_role 'edit-publications'
    @publication = publication
  end

  def create
    require_role 'edit-publications'
    @publication = create_with_audit(Publication, publication_params)
    if @publication.valid?
      redirect_to(@publication)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'edit-publications'
    customer_ids1 = StandingOrder.customer_ids_with_publication_id(publication.id)
    if update_with_audit(publication, publication_params)
      customer_ids2 = StandingOrder.customer_ids_with_publication_id(publication.id)
      customer_ids = (customer_ids1 + customer_ids2).uniq
      customers = Customer.where(id: customer_ids).includes(Customer.sunspot_options(:include))
      Sunspot.index(customers)
      redirect_to(publication)
    else
      render(action: 'edit')
    end
  end

  def show
    redirect_to(issues_path(publication_id: params[:id]))
  end

  def destroy
    require_role 'edit-publications'
    if publication.issues.length > 0
      flash[:notice] = 'Publication could not be deleted: delete each of its Issues first.'
    else
      customer_ids1 = StandingOrder.customer_ids_with_publication_id(publication.id)
      customer_ids2 = WaitingOrder.customer_ids_with_publication_id(publication.id)
      customer_ids = (customer_ids1 + customer_ids2).uniq
      StandingOrder.where(publication_id: publication.id).delete_all
      WaitingOrder.where(publication_id: publication.id).delete_all
      customers = Customer.where(id: customer_ids).includes(Customer.sunspot_options(:include))
      Sunspot.index(customers)
      destroy_with_audit(publication)
    end
    redirect_to(:publications)
  end

  def issue_district_breakdown
    @issue_district_breakdown = IssueDistrictBreakdown.new(publication, params.permit(:start_date_string))
    if !@issue_district_breakdown.start_date
      @issue_district_breakdown.start_date = 1.year.ago.to_date
    end
  end

  def district_breakdown
    @district_breakdown = PublicationDistrictBreakdown.new(params.slice(:start_date_string))
    if !@district_breakdown.start_date
      @district_breakdown.start_date = 1.year.ago.to_date
    end
  end

  protected

  def publication
    @publication ||= Publication.find(params[:id])
  end

  def publication_params
    params.require(:publication).permit(
      :name,
      :tracks_standing_orders,
      :pr_material
    )
  end
end
