module InventoryHelper
  def render_breakdowns(warehouse, issue)
    issue.issue_box_sizes.collect do |ibs|
      wibs = ibs.warehouse_issue_box_sizes.find_or_create_by_warehouse_id(warehouse.id)
      render(:partial => 'breakdown_piece', :locals => { :wibs => wibs }).strip
    end.join('<br/>')
  end
end
