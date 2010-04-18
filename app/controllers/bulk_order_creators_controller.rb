class BulkOrderCreatorsController < ApplicationController
  require_role 'edit-orders'

  def new
    @bulk_order_creator = BulkOrderCreator.new((params[:bulk_order_creator] || {}).merge(:created_by => current_user.id))
  end

  def create
    @bulk_order_creator = BulkOrderCreator.new((params[:bulk_order_creator] || {}).merge(:created_by => current_user.id))

    if @bulk_order_creator.save
      @bulk_order_creator.send_later(:do_copy)
      redirect_to(publication_issue_orders_path(@bulk_order_creator.issue.publication, @bulk_order_creator.issue), :notice => 'Okay, the orders are being created...')
    else
      render(:action => :new)
    end
  end
end
