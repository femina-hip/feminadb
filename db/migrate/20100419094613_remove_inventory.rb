class RemoveInventory < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM versions WHERE versioned_type = 'WarehouseIssueBoxSize'"
    drop_table(:warehouse_issue_box_sizes)
    remove_column(:issues, :num_copies_in_house)
    remove_column(:issues, :inventory_comment)
    remove_column(:warehouses, :tracks_inventory)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new('Inventory is gone forever.')
  end
end
