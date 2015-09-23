class Admin::WarehousesController < ApplicationController
  def index
    @warehouses = Warehouse.order(:name)
  end

  def new
    require_role 'admin'
    @warehouse = Warehouse.new
  end

  def edit
    require_role 'admin'
    @warehouse = warehouse
  end

  def create
    require_role 'admin'
    @warehouse = create_with_audit(Warehouse, warehouse_params)
    if @warehouse.valid?
      redirect_to(admin_warehouses_url)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'admin'
    if update_with_audit(warehouse, warehouse_params)
      redirect_to(admin_warehouses_url)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'admin'
    @warehouse = Warehouse.find(params[:id])

    if @warehouse.delivery_methods.length > 0
      flash[:notice] = 'Could not delete Warehouse: it is used by some DeliveryMethods'
    else
      destroy_with_audit(@warehouse)
    end
    redirect_to(admin_warehouses_url)
  end

  protected

  def warehouse
    @warehouse ||= Warehouse.find(params[:id])
  end

  def warehouse_params
    params.require(:warehouse).permit(:name, :comment)
  end
end
