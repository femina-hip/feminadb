class Admin::CustomerTypesController < ApplicationController
  require_role 'admin'

  make_resourceful do
    actions :index, :show, :new, :create, :edit, :update
  end

  # DELETE /customer_types/1
  # DELETE /customer_types/1.xml
  def destroy
    @customer_type = CustomerType.find(params[:id])

    respond_to do |format|
      if @customer_type.soft_delete(:updated_by => current_user)
        flash[:notice] = 'CustomerType successfully deleted'
        format.html { redirect_to admin_customer_types_url }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Could not delete CustomerType: it is used by some Customers'
        format.html { redirect_to admin_customer_types_url }
        format.xml  { render :xml => @customer_type.errors.to_xml }
      end
    end
  end

  protected

  def url_helper_prefix
    "admin_"
  end

  def current_objects
    @current_objects ||= CustomerType.active.order([:category, :name]).all
  end

  def object_parameters
    params[current_model_name.underscore] && params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
