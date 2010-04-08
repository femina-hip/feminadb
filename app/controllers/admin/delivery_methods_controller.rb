class Admin::DeliveryMethodsController < ApplicationController
  require_role 'admin'

  make_resourceful do
    actions :index, :show, :new, :create, :edit, :update
  end

  # DELETE /delivery_methods/1
  # DELETE /delivery_methods/1.xml
  def destroy
    @delivery_method = DeliveryMethod.find(params[:id])

    success = true
    begin
      @delivery_method.destroy
    rescue ActiveRecord::ReferentialIntegrityProtectionError
      success = false
    end

    respond_to do |format|
      if @delivery_method.customers.length == 0 && @delivery_method.orders.length == 0
        @delivery_method.update_attributes!(:deleted_at => Time.now, :updated_by => current_user)
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
    @current_objects ||= DeliveryMethod.where(:deleted_at => nil).order(:name).all
  end
end
