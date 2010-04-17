class Admin::DeliveryMethodsController < ApplicationController
  require_role 'admin'

  make_resourceful do
    actions :index, :show, :new, :create, :edit, :update
  end

  # DELETE /delivery_methods/1
  # DELETE /delivery_methods/1.xml
  def destroy
    @delivery_method = DeliveryMethod.find(params[:id])

    respond_to do |format|
      if !@delivery_method.soft_delete_would_delete_protected_dependents?
        @delivery_method.soft_delete!
        flash[:notice] = 'DeliveryMethod was successfully deleted.'
        format.html { redirect_to admin_delivery_methods_url }
        format.xml  { head :ok }
      else
        flash[:notice] = 'DeliveryMethod could not be deleted: it is in use by Customers and/or Orders'
        format.html { redirect_to admin_delivery_methods_url }
        format.xml  { render :xml => @delivery_method.errors.to_xml }
      end
    end
  end

  protected

  def url_helper_prefix
    "admin_"
  end

  def current_objects
    @current_objects ||= DeliveryMethod.active.order(:name).all
  end
end
