class BulkOrderCreatorsController < ApplicationController
  def new
    require_role 'edit-orders'
    @bulk_order_creator = BulkOrderCreator.new(bulk_order_creator_params)
  end

  def create
    require_role 'edit-orders'
    @bulk_order_creator = BulkOrderCreator.new(bulk_order_creator_params)
    audit_create(@bulk_order_creator)

    @bulk_order_creator.do_copy
    redirect_to(issue_orders_path(@bulk_order_creator.issue), :notice => 'New orders created')
  end

  private

  def bulk_order_creator_params
    params.require(:bulk_order_creator).permit(
      :issue_id,
      :from_publication_id,
      :from_issue_id,
      :search_string,
      :constant_num_copies,
      :num_copies,
      :comment,
      :delivery_method_id,
      :order_date_string
    )
  end
end
