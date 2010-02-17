class AlterSpecialOrdersAddCommentsAndDenial < ActiveRecord::Migration
  def self.up
    add_column :special_orders, :authorize_comments, :string, :null => false, :default => ''
    add_column :special_orders, :approved, :boolean, :null => false, :default => false
    add_column :special_order_versions, :authorize_comments, :string, :null => false, :default => ''
    add_column :special_order_versions, :approved, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :special_orders, :authorize_comments
    remove_column :special_orders, :approved
    remove_column :special_order_versions, :authorize_comments
    remove_column :special_order_versions, :approved
  end
end
