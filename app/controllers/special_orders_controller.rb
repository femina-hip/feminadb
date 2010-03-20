class SpecialOrdersController < ApplicationController
  require_role 'edit-special-orders', :only => [ :approve, :deny, :complete ]
  before_filter :login_required, :except => [ :index, :show ]

  # GET /special_orders
  def index
    @pending_special_orders = SpecialOrder.pending.all(
      :order => 'special_orders.requested_at DESC',
      :include => [ :requested_by_user, :lines ]
    )
    @approved_special_orders = SpecialOrder.incomplete_approved.all(
      :order => 'special_orders.requested_at DESC',
      :include => [ :requested_by_user, :authorized_by_user, :lines ]
    )
    @special_orders = SpecialOrder.all.paginate(
      :order => 'special_orders.requested_for_date DESC, special_orders.requested_at DESC',
      :include => [ :requested_by_user, :authorized_by_user, :lines ],
      :page => (params[:page] || 1).to_i
    )
  end

  # GET /special_orders/1
  def show
    @special_order = SpecialOrder.find(params[:id])

    if @special_order.state == :pending
      @special_order.lines.each do |line|
        line.num_copies = line.num_copies_requested
      end
    end

    action = case @special_order.state
    when :denied then 'show_denied'
    when :approved then 'show_approved'
    when :completed then 'show_completed'
    when :pending then 'show_pending'
    end

    render :action => action
  end

  # GET /special_orders/new
  def new
    @special_order = SpecialOrder.new(
      :requested_by => current_user.id,
      :requested_at => DateTime.now,
      :requested_for_date => Date.today
    )

    if params[:customer_id]
      @special_order.customer_id = params[:customer_id].to_i
    else
      @special_order.customer_name = current_user.login
    end

    @special_order.lines.build # Creates a first line
  end

  def add_new_line
    @line = SpecialOrderLine.new
  end

  # POST /special_orders
  def create
    @special_order = SpecialOrder.new(params[:special_order])
    @special_order.requested_by = current_user.id
    @special_order.requested_at = DateTime.now
    @special_order.customer_name = @special_order.customer.name if @special_order.customer
    params[:lines].each_value do |line|
      @special_order.lines.build line
    end

    if @special_order.save
      flash[:notice] = 'Request for Copies was successfully filed.'
      redirect_to :action => 'show', :id => @special_order.id
    else
      render :action => 'new'
    end
  end

  # PUT /special_orders/1/approve
  def approve
    @special_order = SpecialOrder.find(params[:id])

    @special_order.attributes = params[:special_order]
    @special_order.approve(current_user)
    @special_order.lines.each do |line|
      line.attributes = params[:lines][line.id.to_s]
    end

    saved = true
    begin
      SpecialOrder.transaction do
        @special_order.save!
        @special_order.lines.each do |line|
          line.save!
          if line.num_copies.to_i != 0
            line.issue.num_copies_in_house -= line.num_copies.to_i
            line.issue.save!
          end
        end
      end
    rescue ActiveRecord::RecordNotSaved
      saved = false
    end

    if saved
      flash[:notice] = 'Special Order was approved; inventory was adjusted.'
      redirect_to :action => 'index'
    else
      render :action => 'show_pending'
    end
  end

  # PUT /special_orders/1/deny
  def deny
    @special_order = SpecialOrder.find(params[:id])

    @special_order.attributes = params[:special_order]
    @special_order.deny(current_user)

    if @special_order.save
      flash[:notice] = 'Special Order was denied.'
      redirect_to :action => 'index'
    else
      render :action => 'show_pending'
    end
  end

  # PUT /special_orders/1/complete
  def complete
    @special_order = SpecialOrder.find(params[:id])

    @special_order.attributes = params[:special_order]
    @special_order.complete(current_user)

    if @special_order.save
      flash[:notice] = 'Special Order is now complete.'
      redirect_to :action => 'index'
    else
      render :action => 'show_approved'
    end
  end
end
