class AddIssueQuantity < ActiveRecord::Migration
  def self.up
    add_column :issues, :quantity, :integer, :null => false, :default => 0
    add_column :issue_versions, :quantity, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :issues, :quantity
    remove_column :issue_versions, :quantity
  end
end
