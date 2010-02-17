class StandingOrdersToOrdersController < ApplicationController
  layout 'progress_bar_page'
  require_role 'edit-orders'
  verify :only => :start_task, :method => :post
  verify :only => :update_progress_bar, :method => :get,
         :xhr => true, :session => :standing_order_to_order_key

  def start_task
    session[:standing_order_to_order_key] =
        ::MiddleMan.new_worker(:class => :s_to_o_worker, :args => { :issue_id => params[:id], :recipients => [ current_user.email ] })
    respond_to do |format|
      format.html { render :action => :progress }
    end
  end

  def update_progress_bar
    begin
      worker = ::MiddleMan.worker(session[:standing_order_to_order_key])
    rescue NoMethodError
    end

    if worker.nil?
      flash[:info] = 'Finished processing. Check your email for results'
      render :update do |page|
        page.redirect_to publications_url
      end
      return
    end

    r = worker.results.to_hash

    @percent = 0
    if r[:num_standing_orders] > 0
      @percent = 100.0 * r[:num_complete] / r[:num_standing_orders]
    end

    @msg = 'Working...'
    if not r[:current_standing_order_id].nil?
      @msg = "Processing Customer “#{StandingOrder.find(r[:current_standing_order_id], :include => :customer).customer.name}” (#{r[:num_complete]}/#{r[:num_standing_orders]})..."
    end

    render :action => 'update_progress_bar'
  end
end
