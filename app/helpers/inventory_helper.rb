module InventoryHelper
  def render_breakdowns(warehouse, issue)
    issue.issue_box_sizes.collect do |ibs|
      wibs = ibs.warehouse_issue_box_sizes.select{|wibs| wibs.warehouse_id = warehouse.id}.first
      if !wibs
        wibs = ibs.warehouse_issue_box_sizes.create(:warehouse_id => warehouse.id, :num_boxes => 0)
      end
      render(:partial => 'breakdown_piece', :locals => { :wibs => wibs }).strip
    end.join('<br/>').html_safe
  end
end
