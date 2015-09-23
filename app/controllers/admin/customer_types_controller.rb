class Admin::CustomerTypesController < ApplicationController
  def index
    @customer_types = CustomerType.order(:category, :name).all
  end

  def new
    require_role 'admin'
    @customer_type = CustomerType.new
  end

  def edit
    require_role 'admin'
    @customer_type = customer_type
  end

  def create
    require_role 'admin'
    @customer_type = create_with_audit(CustomerType, customer_type_params)
    if @customer_type.valid?
      redirect_to(admin_customer_types_url)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'admin'
    if update_with_audit(customer_type, customer_type_params)
      redirect_to(admin_customer_types_url)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'admin'
    if customer_type.customers.length > 0
      flash[:notice] = 'Could not delete CustomerType: it is used by some Customers'
    else
      destroy_with_audit(customer_type)
    end
    redirect_to(admin_customer_types_url)
  end

  protected

  def customer_type
    @customer_type ||= CustomerType.find(params[:id])
  end

  def customer_type_params
    params.require(:customer_type).permit(:name, :description, :category)
  end
end
