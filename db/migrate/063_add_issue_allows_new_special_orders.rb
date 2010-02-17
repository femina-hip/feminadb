class AddIssueAllowsNewSpecialOrders < ActiveRecord::Migration
  def self.up
    add_column :issues, :allows_new_special_orders, :boolean, :null => false, :default => true
    add_column :issue_versions, :allows_new_special_orders, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :issues, :allows_new_special_orders
    remove_column :issue_versions, :allows_new_special_orders
  end
end
