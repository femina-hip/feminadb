class IndexOrdersForBulkCreate < ActiveRecord::Migration
  def self.up
    add_index(:orders, [:standing_order_id, :issue_id, :deleted_at])
  end

  def self.down
    remove_index(:orders, [:standing_order_id, :issue_id, :deleted_at])
  end
end
