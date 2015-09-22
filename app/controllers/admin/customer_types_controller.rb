class Admin::CustomerTypesController < ApplicationController
  make_resourceful do
    actions :index, :new, :create, :edit, :update

    before(:index, :new, :create, :edit, :update) do
      require_role 'admin'
    end

    response_for(:update) do |format|
      format.html { redirect_to(admin_customer_types_url, :notice => "Customer Type \"#{current_object.name}\" updated") }
    end
    response_for(:create) do |format|
      format.html { redirect_to(admin_customer_types_url, :notice => "Customer Type \"#{current_object.name}\" created") }
    end
  end

  # DELETE /customer_types/1
  # DELETE /customer_types/1.xml
  def destroy
    require_role 'admin'
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
    @current_objects ||= CustomerType.order([:category, :name]).all
  end

  def object_parameters
    params[current_model_name.underscore] && params[current_model_name.underscore].merge(:updated_by => current_user)
  end
end
