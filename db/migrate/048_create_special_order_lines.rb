class CreateSpecialOrderLines < ActiveRecord::Migration
  def self.up
    create_table :special_order_lines do |t|
      t.integer :special_order_id, :null => false
      t.integer :issue_id, :null => false
      t.integer :num_copies_requested, :null => false
      t.integer :num_copies
      t.datetime :updated_at, :null => false
      t.integer :updated_by, :null => false
      t.integer :version, :null => false
      t.datetime :deleted_at
    end
    SpecialOrderLine.create_versioned_table

    SpecialOrder.delete_all
    remove_column :special_orders, :issue_id
    remove_column :special_orders, :num_copies_requested
    remove_column :special_orders, :num_copies
    remove_column :special_order_versions, :issue_id
    remove_column :special_order_versions, :num_copies_requested
    remove_column :special_order_versions, :num_copies
  end

  def self.down
    SpecialOrderLine.delete_all
    SpecialOrder.delete_all

    SpecialOrderLine.drop_versioned_table
    drop_table :special_order_lines

    add_column :special_orders, :issue_id, :int, :null => false
    add_column :special_orders, :num_copies_requested, :int, :null => false
    add_column :special_orders, :num_copies, :int
    add_column :special_order_versions, :issue_id, :int, :null => false
    add_column :special_order_versions, :num_copies_requested, :int, :null => false
    add_column :special_order_versions, :num_copies, :int
  end
end
