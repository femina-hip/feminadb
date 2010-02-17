class RenameSubscriptionsToStandingOrders < ActiveRecord::Migration
  def self.up
    remove_index :subscriptions, 'customer_id_and_publication_id'

    rename_column :orders, :subscription_id, :standing_order_id
    rename_column :order_versions, :subscription_id, :standing_order_id
    rename_column :subscription_versions, :subscription_id, :standing_order_id

    rename_table :subscriptions, :standing_orders
    rename_table :subscription_versions, :standing_order_versions

    add_index :standing_orders, [ :customer_id, :publication_id ], :name => 'index_standing_orders_on_customer_id_and_publication_id'
  end

  def self.down
    remove_index :standing_orders, 'customer_id_and_publication_id'

    rename_column :orders, :standing_order_id, :subscription_id
    rename_column :order_versions, :standing_order_id, :subscription_id
    rename_column :standing_order_versions, :standing_order_id, :subscription_id

    rename_table :standing_orders, :subscriptions
    rename_table :standing_order_versions, :subscription_versions

    add_index :subscriptions, [ :customer_id, :publication_id ]
  end
end
