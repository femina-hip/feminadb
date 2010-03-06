class RegionsController < ApplicationController
  require_role 'admin'

  make_resourceful do
    actions :index, :show, :new, :create, :edit, :update
  end

  # DELETE /regions/1
  # DELETE /regions/1.xml
  def destroy
    @region = Region.find(params[:id])

    respond_to do |format|
      begin
        @region.destroy
        flash[:notice] = 'Region successfully deleted'
        format.html { redirect_to admin_regions_url }
        format.xml  { head :ok }
      rescue ActiveRecord::ReferentialIntegrityProtectionError
        flash[:notice] = 'Could not delete Region: it is used by some Customers/Orders'
        format.html { redirect_to admin_regions_url }
        format.xml  { render :xml => @region.errors.to_xml }
      end
    end
  end

  protected

  def url_helper_prefix
    "admin_"
  end

  def current_objects
    @current_objects ||= Region.where(:deleted_at => nil).order(:name).all
  end
end
