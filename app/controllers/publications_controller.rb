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
    if update_with_audit(publication, publication_params)
      redirect_to(publication)
    else
      render(action: 'edit')
    end
  end

  def show
    redirect_to(issues_path(publication_id: params[:publication_id]))
  end

  def destroy
    require_role 'edit-publications'
    if !destroy_with_audit(publication)
      flash[:notice] = 'Publication could not be deleted: delete each of its Issues first.'
    end
    redirect_to(:publications)
  end

  def issue_district_breakdown
    @issue_district_breakdown = IssueDistrictBreakdown.new(publication, params.slice(:start_date_string))
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
      :pr_material,
      :packing_hints
    )
  end
end
