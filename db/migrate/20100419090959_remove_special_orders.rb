class RemoveSpecialOrders < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM versions WHERE versioned_type = 'SpecialOrder'"
    drop_table(:special_order_notes)
    drop_table(:special_order_lines)
    drop_table(:special_orders)
    remove_column(:issues, :allows_new_special_orders)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new('Special Orders are gone forever.')
  end
end
