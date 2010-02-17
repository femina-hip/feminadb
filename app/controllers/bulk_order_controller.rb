class BulkOrderController < ApplicationController
  require_role 'edit-orders'
  verify :only => :run, :method => :post
  verify :only => :prepare, :method => :get
  verify :only => :update_progress_bar, :method => :get,
         :xhr => true, :session => :bulk_order_key

  def prepare
    @customers = customers
    @creation_type = creation_type
    if @creation_type == :publication
      @from_publication = Publication.find(params[:from_publication_id])
    elsif @creation_type == :issue
      @from_issue = Issue.find(params[:from_issue_id])
    end
  end

  def run
    options = {}
    options[:issue_id] = params[:issue_id]
    options[:q] = params[:q]
    options[:from_issue_id] = params[:from_issue_id] if params[:from_issue_id]
    options[:from_publication_id] = params[:from_publication_id] if params[:from_publication_id]
    options[:num_copies] = params[:num_copies].to_i if params[:enable_num_copies] == 'true'
    options[:delivery_method_id] = params[:delivery_method_id] if params[:delivery_method_id].to_i > 0
    options[:comments] = params[:comments] unless params[:comments].to_s.strip.empty?
    options[:recipients] = [ current_user.email ]

    Customer.logger.info("XXXX #{options.inspect} XXXX")

    validated = true
    if !options[:from_issue_id] && !options[:from_publication_id] && options[:num_copies].to_i <= 0
      flash[:notice] = 'Please enter a number of copies'
      validated = false
    end
    if options[:issue_id].to_i <= 0
      flash[:notice] = 'Please enter an Issue'
      validated = false
    end
    if options[:enable_num_copies] == 'true' and options[:num_copies].to_i <= 0
      flash[:notice] = 'Please enter a number of copies'
      validated = false
    end

    unless validated
      prepare
      render :action => :prepare
      return
    end

    session[:bulk_order_key] =
      ::MiddleMan.new_worker(:class => :bulk_order_worker, :args => options)
    render :action => :progress, :layout => 'progress_bar_page'
  end

  def update_progress_bar
    begin
      worker = ::MiddleMan.worker(session[:bulk_order_key])
    rescue NoMethodError
    end

    if worker.nil?
      flash[:notice] = 'Orders all created (unless you were emailed).'
      render :update do |page|
        page.redirect_to publications_url
      end
      return
    end

    r = worker.results.to_hash

    @msg = 'Working... (Sorry there is no progress bar...)'

    render :action => 'update_progress_bar'
  end

  private
    def creation_type
      if params[:from_publication_id]
        :publication
      elsif params[:from_issue_id]
        :issue
      else
        :customers
      end
    end

    def customers
      case creation_type
      when :publication then BulkOrderCreator.find_customers_from_publication_id(params[:from_publication_id].to_i, params[:q])
      when :issue then BulkOrderCreator.find_customers_from_issue_id(params[:from_issue_id].to_i, params[:q])
      when :customers then BulkOrderCreator.find_customers(params[:q])
      end
    end
end
