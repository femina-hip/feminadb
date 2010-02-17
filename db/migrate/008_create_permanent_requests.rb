class CreatePermanentRequests < ActiveRecord::Migration
  def self.up
    create_table :permanent_requests do |t|
      t.column :customer_id, :int
      t.column :publication_id, :int
      t.column :num_copies, :int
      t.column :comments, :string
      t.column :updated_at, :datetime
      t.column :updated_by, :int
      t.column :version, :int
    end
    rename_table :permanent_requests, :subscriptions
    Subscription.create_versioned_table
  end

  def self.down
    Subscription.drop_versioned_table
    drop_table :subscriptions
  end
end
