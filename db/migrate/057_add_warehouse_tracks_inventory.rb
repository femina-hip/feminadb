class AddWarehouseTracksInventory < ActiveRecord::Migration
  def self.up
    add_column :warehouses, :tracks_inventory, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :warehouses, :tracks_inventory
  end
end
