class UpdatedByNotRequired < ActiveRecord::Migration
  def self.up
    change_column :clubs, :updated_at, :datetime, :null => true
    change_column :clubs, :updated_by, :datetime, :null => true
    change_column :districts, :updated_at, :datetime, :null => true
    change_column :districts, :updated_by, :datetime, :null => true
    change_column :special_order_lines, :updated_at, :datetime, :null => true
    change_column :special_order_lines, :updated_by, :datetime, :null => true
    change_column :special_orders, :updated_at, :datetime, :null => true
    change_column :special_orders, :updated_by, :datetime, :null => true
    change_column :waiting_orders, :updated_at, :datetime, :null => true
    change_column :waiting_orders, :updated_by, :datetime, :null => true
  end

  def self.down
    change_column :clubs, :updated_at, :datetime, :null => false
    change_column :clubs, :updated_by, :datetime, :null => false
    change_column :districts, :updated_at, :datetime, :null => false
    change_column :districts, :updated_by, :datetime, :null => false
    change_column :special_order_lines, :updated_at, :datetime, :null => false
    change_column :special_order_lines, :updated_by, :datetime, :null => false
    change_column :special_orders, :updated_at, :datetime, :null => false
    change_column :special_orders, :updated_by, :datetime, :null => false
    change_column :waiting_orders, :updated_at, :datetime, :null => false
    change_column :waiting_orders, :updated_by, :datetime, :null => false
  end
end
