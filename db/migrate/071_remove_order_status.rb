class RemoveOrderStatus < ActiveRecord::Migration
  def self.up
    drop_table :order_statuses
    remove_column :orders, :order_status_id
    remove_column :order_versions, :order_status_id
  end

  def self.down
    create_table :order_statuses do |t|
      t.column :name, :string
    end
    add_column :orders, :order_status_id, :integer
    add_column :order_versions, :order_status_id, :integer
  end
end
