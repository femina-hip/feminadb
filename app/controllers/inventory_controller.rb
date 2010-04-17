class InventoryController < ApplicationController
  require_role 'edit-inventory', :except => :index

  in_place_edit_for :warehouse_issue_box_size, 'num_boxes'
  in_place_edit_for :issue, 'num_copies_in_house'
  in_place_edit_for :issue, 'inventory_comment'

  def index
    @publications = Publication.active.includes(:issues => { :issue_box_sizes => :warehouse_issue_box_sizes }).order('publications.name, issues.issue_number DESC, issue_box_sizes.num_copies').all # FIXME test this works
    @warehouses = Warehouse.find_all_inventory(:order => :name)
  end
end
