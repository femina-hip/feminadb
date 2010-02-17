class AddIssueInventoryCommentAndRemoveOnHold < ActiveRecord::Migration
  def self.up
    remove_column :issues, :num_copies_on_hold
    remove_column :issue_versions, :num_copies_on_hold
    add_column :issues, :inventory_comment, :string, :null => false, :default => ''
    add_column :issue_versions, :inventory_comment, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :issues, :inventory_comment
    remove_column :issue_versions, :inventory_comment
    add_column :issues, :num_copies_on_hold, :integer, :null => false, :default => 0
    add_column :issue_versions, :num_copies_on_hold, :integer, :null => false, :default => 0
  end
end
