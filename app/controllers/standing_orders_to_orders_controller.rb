class StandingOrdersToOrdersController < ApplicationController
  require_role 'edit-orders'

  def start_task
    issue = Issue.includes(:publication).find(params[:id])
    BulkOrderCreator.new.send_later(:do_copy_from_publication, :issue_id => issue.id, :from_publication_id => issue.publication_id, :comments => 'Automatic from Standing Order')
    redirect_to([issue.publication, issue], :notice => 'Okay, we\'re working on those standing orders. Wait a minute or two.')
  end
end
