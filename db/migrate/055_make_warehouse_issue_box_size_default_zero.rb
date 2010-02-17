class MakeWarehouseIssueBoxSizeDefaultZero < ActiveRecord::Migration
  def self.up
    change_column :warehouse_issue_box_sizes, :num_boxes, :integer, :null => false, :default => 0
    change_column :warehouse_issue_box_size_versions, :num_boxes, :integer, :null => false, :default => 0
  end

  def self.down
    change_column :warehouse_issue_box_sizes, :num_boxes, :integer
    change_column :warehouse_issue_box_size_versions, :num_boxes, :integer
  end
end
