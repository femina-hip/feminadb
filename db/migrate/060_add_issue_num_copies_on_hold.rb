class AddIssueNumCopiesOnHold < ActiveRecord::Migration
  def self.up
    add_column :issues, :num_copies_on_hold, :integer, :null => false, :default => 0
    add_column :issue_versions, :num_copies_on_hold, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :issues, :num_copies_on_hold
    remove_column :issue_versions, :num_copies_on_hold
  end
end
