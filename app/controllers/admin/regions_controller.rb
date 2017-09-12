class Admin::RegionsController < ApplicationController
  def index
    @regions = Region.order(:name).all
  end

  def new
    require_role 'admin'
    @region = Region.new
  end

  def edit
    require_role 'admin'
    @region = region
  end

  def create
    require_role 'admin'
    @region = create_with_audit(Region, region_params)
    if @region.valid?
      redirect_to(admin_regions_url)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'admin'
    if update_with_audit(region, region_params)
      customers = Customer.where(region_id: region.id).includes(Customer.sunspot_options[:include])
      Sunspot.index(customers)
      redirect_to(admin_regions_url)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'admin'
    if region.customers.length > 0
      flash[:notice] = 'Could not delete Region: it is used by some Customers'
    else
      destroy_with_audit(region)
    end
    redirect_to(admin_regions_url)
  end

  private

  def region
    @region ||= Region.find(params[:id])
  end

  def region_params
    params.require(:region).permit(:name, :population, :delivery_method_id, :councils_separated_by_newline)
  end
end
