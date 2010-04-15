class PublicationsController < ApplicationController
  require_role 'edit-publications', :except => [ :index, :show, :district_breakdown, :issue_district_breakdown ]

  make_resourceful do
    actions :index, :new, :create, :edit, :update

    response_for(:create) do |format|
      format.html do
        set_default_flash :notice, 'Publication was successfully created.'
        set_default_redirect(objects_path)
      end
      format.xml  { head :ok }
    end

    response_for(:update) do |format|
      format.html do
        set_default_flash :notice, 'Publication was successfully updated.'
        set_default_redirect(objects_path)
      end
      format.xml  { head :ok }
    end

  end

  def show
    respond_to do |format|
      format.html { redirect_to publication_issues_path(params[:id]) }
      format.xml do
        @publication = Publication.find(params[:id])
        render :xml => @publication.to_xml
      end
    end
  end

  # DELETE /delivery_methods/1
  # DELETE /delivery_methods/1.xml
  def destroy
    @publication = Publication.find(params[:id])

    success = @publication.soft_delete(:updated_by => current_user)

    respond_to do |format|
      if success
        flash[:notice] = 'Publication was successfully deleted.'
        format.html { redirect_to publications_url }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Publication could not be deleted: delete each of its Issues first.'
        format.html { redirect_to publications_url }
        format.xml  { render :xml => @delivery_method.errors.to_xml }
      end
    end
  end

  def issue_district_breakdown
    @publication = Publication.find(params[:id])
    @data = IssueDistrictBreakdown.new(@publication).data
  end

  def district_breakdown
    @publications = Publication.where(:deleted_at => nil).order(:name).all
    @data = PublicationDistrictBreakdown.new.data
  end

  protected

  def current_objects
    @current_objects ||= Publication.where(:deleted_at => nil).order(:name).all
  end

  def object_parameters
    params[current_model_name.underscore] && params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
