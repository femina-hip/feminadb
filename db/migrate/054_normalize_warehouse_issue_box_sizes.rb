class NormalizeWarehouseIssueBoxSizes < ActiveRecord::Migration
  def self.up
    remove_column :warehouse_issue_box_sizes, :num_copies
    remove_column :warehouse_issue_box_sizes, :issue_id
    remove_column :warehouse_issue_box_size_versions, :num_copies
    remove_column :warehouse_issue_box_size_versions, :issue_id
  end

  def self.down
    add_column :warehouse_issue_box_sizes, :num_copies, :integer
    add_column :warehouse_issue_box_sizes, :issue_id, :integer
    add_column :warehouse_issue_box_size_versions, :num_copies, :integer
    add_column :warehouse_issue_box_size_versions, :issue_id, :integer
  end
end
