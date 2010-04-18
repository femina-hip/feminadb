class InventoryController < ApplicationController
  require_role 'edit-inventory', :except => :index

  in_place_edit_for :warehouse_issue_box_size, 'num_boxes'
  in_place_edit_for :issue, 'num_copies_in_house'
  in_place_edit_for :issue, 'inventory_comment'

  def show
    @publications = Publication.active.order(:name)
    Publication.send(:preload_associations, @publications, { :issues => [:publication, { :issue_box_sizes => { :warehouse_issue_box_sizes => [ :warehouse, :issue_box_size ] } }] })
    @warehouses = Warehouse.inventory.order(:name)
  end
end
