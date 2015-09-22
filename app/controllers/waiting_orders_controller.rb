class WaitingOrdersController < ApplicationController
  respond_to(:html, :js)

  def convert_to_standing_order
    require_role 'edit-orders'
    @waiting_order = WaitingOrder.find(params[:id])
    @standing_order = @waiting_order.convert_to_standing_order(:updated_by => current_user)
    flash[:notice] = 'Waiting Order created' if @standing_order
    respond_with(@standing_order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  def create
    require_role 'edit-orders'
    @waiting_order = WaitingOrder.new(waiting_order_param)
    flash[:notice] = 'Waiting Order created' if @waiting_order.save
    respond_with(@waiting_order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  def update
    require_role 'edit-orders'
    @waiting_order = WaitingOrder.find(params[:id])
    flash[:notice] = 'Waiting Order updated' if @waiting_order.update_attributes(waiting_order_param)
    respond_with(@waiting_order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  def destroy
    require_role 'edit-orders'
    @waiting_order = WaitingOrder.find(params[:id])
    flash[:notice] = 'Waiting Order destroyed' if @waiting_order.soft_delete(:updated_by => current_user)
    respond_with(@waiting_order, :location => redirect_location) do |format|
      format.js { render_json_response }
    end
  end

  private

  def render_json_response
    render(:json => {
      'td_html' => render_to_string(:partial => 'customers/standing_or_waiting_order', :locals => {
        :customer => @waiting_order.customer,
        :publication => @waiting_order.publication,
        :waiting_order => @waiting_order.deleted_at.nil? ? @waiting_order : nil,
        :standing_order => @standing_order # if converted
      })
    })
  end

  def waiting_order_param
    (params[:waiting_order] || {}).merge(:updated_by => current_user)
  end

  def redirect_location
    customers_path(:q => "waiting:#{@waiting_order.publication.to_index_key}:true")
  end
end
