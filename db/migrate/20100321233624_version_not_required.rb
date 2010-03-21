class VersionNotRequired < ActiveRecord::Migration
  def self.up
    change_column :clubs, :version, :integer, :null => true
    change_column :districts, :version, :integer, :null => true
    change_column :special_order_lines, :version, :integer, :null => true
    change_column :special_orders, :version, :integer, :null => true
    change_column :waiting_orders, :version, :integer, :null => true
  end

  def self.down
    change_column :clubs, :version, :integer, :null => false
    change_column :districts, :version, :integer, :null => false
    change_column :special_order_lines, :version, :integer, :null => false
    change_column :special_orders, :version, :integer, :null => false
    change_column :waiting_orders, :version, :integer, :null => false
  end
end
