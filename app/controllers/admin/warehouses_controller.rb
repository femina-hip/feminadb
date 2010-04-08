class Admin::WarehousesController < ApplicationController
  require_role 'admin'

  make_resourceful do
    actions :index, :show, :new, :create, :edit, :update
  end

  # DELETE /warehouses/1
  # DELETE /warehouses/1.xml
  def destroy
    @warehouse = Warehouse.find(params[:id])

    respond_to do |format|
      if !@warehouse.delivery_methods.empty?
        @warehouse.update_attributes(:deleted_at => Time.now, :updated_by => current_user)
        format.html { redirect_to admin_warehouses_url }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Could not delete Warehouse: it is used by some DeliveryMethods'
        format.html { redirect_to admin_warehouses_url }
        format.xml  { render :xml => @warehouse.errors.to_xml }
      end
    end
  end

  protected

  def url_helper_prefix
    "admin_"
  end

  def current_objects
    @current_objects ||= Warehouse.order(:name).all
  end
end
