class AddPublicationTracksStandingOrders < ActiveRecord::Migration
  def self.up
    add_column :publications, :tracks_standing_orders, :boolean, :null => false, :default => true
    add_column :publication_versions, :tracks_standing_orders, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :publications, :tracks_standing_orders
    remove_column :publication_versions, :tracks_standing_orders
  end
end
