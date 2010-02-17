class CreateMoreOrderIndexes < ActiveRecord::Migration
  def self.up
    add_index :standing_orders, :publication_id
    add_index :standing_orders, :customer_id
    add_index :orders, :issue_id
    add_index :orders, :customer_id
    add_index :special_order_lines, :issue_id
    add_index :special_orders, :customer_id
  end

  def self.down
    remove_index :standing_orders, :publication_id
    remove_index :standing_orders, :customer_id
    remove_index :orders, :issue_id
    remove_index :orders, :customer_id
    remove_index :special_order_lines, :issue_id
    remove_index :special_orders, :customer_id
  end
end
