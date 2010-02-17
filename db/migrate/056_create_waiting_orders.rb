class CreateWaitingOrders < ActiveRecord::Migration
  def self.up
    create_table :waiting_orders do |t|
      t.integer :customer_id, :null => false
      t.integer :publication_id, :null => false
      t.integer :num_copies, :null => false
      t.string :comments, :null => false, :default => ''

      t.column :updated_at, :datetime, :null => false
      t.column :updated_by, :int, :null => false
      t.column :version, :int, :null => false
      t.column :deleted_at, :datetime
    end
    WaitingOrder.create_versioned_table
  end

  def self.down
    WaitingOrder.drop_versioned_table
    drop_table :waiting_orders
  end
end
