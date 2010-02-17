class CreateSpecialOrders < ActiveRecord::Migration
  def self.up
    create_table :special_orders do |t|
      t.column :issue_id, :int, :null => false, :default => 0
      t.column :num_copies_requested, :int, :null => false, :default => 0
      t.column :num_copies, :int
      t.column :customer_id, :int, :default => :null, :default => 0
      t.column :customer_name, :string, :null => false, :default => ''
      t.column :reason, :string, :null => false, :default => ''
      t.column :requested_at, :datetime, :null => false
      t.column :requested_for_date, :date, :null => false
      t.column :received_by, :string, :null => false, :default => ''
      t.column :authorized_by, :int
      t.column :authorized_at, :datetime
      t.column :updated_at, :datetime, :null => false
      t.column :updated_by, :int, :null => false
      t.column :version, :int, :null => false
      t.column :deleted_at, :datetime
    end
    SpecialOrder.create_versioned_table
  end

  def self.down
    SpecialOrder.drop_versioned_table
    drop_table :special_orders
  end
end
