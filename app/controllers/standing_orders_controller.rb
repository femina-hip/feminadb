class StandingOrdersController < ApplicationController
  respond_to(:html, :js)

  def create
    require_role 'edit-orders'
    @standing_order = StandingOrder.new(standing_order_param)
    flash[:notice] = 'Standing Order created' if @standing_order.save
    respond_with(@standing_order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  def update
    require_role 'edit-orders'
    @standing_order = StandingOrder.find(params[:id])
    flash[:notice] = 'Standing Order updated' if @standing_order.update_attributes(standing_order_param)
    respond_with(@standing_order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  def destroy
    require_role 'edit-orders'
    @standing_order = StandingOrder.find(params[:id])
    flash[:notice] = 'Standing Order destroyed' if @standing_order.soft_delete(:updated_by => current_user)
    respond_with(@standing_order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  private

  def render_json_response
    render(:json => {
      'td_html' => render_to_string(:partial => 'customers/standing_or_waiting_order', :locals => {
        :customer => @standing_order.customer,
        :publication => @standing_order.publication,
        :standing_order => @standing_order.deleted_at.nil? ? @standing_order : nil
      })
    })
  end

  def standing_order_param
    (params[:standing_order] || {}).merge(:updated_by => current_user)
  end

  def redirect_location
    customers_path(:q => "standing:#{@standing_order.publication.to_index_key}:true")
  end
end
