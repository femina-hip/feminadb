class BulkOrderCreatorsController < ApplicationController
  require_role 'edit-orders'

  def new
    @bulk_order_creator = BulkOrderCreator.new((params[:bulk_order_creator] || {}).merge(:updated_by => current_user, :recipients => [current_user.email]))
  end

  def create
    @bulk_order_creator = BulkOrderCreator.new((params[:bulk_order_creator] || {}).merge(:updated_by => current_user, :recipients => [current_user.email]))

    if @bulk_order_creator.invalid?
      @errors = @bulk_order_creator.errors
      render(:action => :new)
      return
    end

    @bulk_order_creator.send_later(:do_copy)

    redirect_to(publication_issue_orders_path(@bulk_order_creator.issue.publication, @bulk_order_creator.issue), :notice => 'Okay, the orders are being created...')
  end
end
