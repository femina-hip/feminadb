class AddSubscriptionsCustomerIdIndex < ActiveRecord::Migration
  def self.up
    add_index :subscriptions, [ :customer_id, :publication_id ]
  end

  def self.down
    remove_index :subscriptions, [ :customer_id, :publication_id ]
  end
end
