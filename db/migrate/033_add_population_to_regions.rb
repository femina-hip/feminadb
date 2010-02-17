class AddPopulationToRegions < ActiveRecord::Migration
  def self.up
    add_column :regions, :population, :integer
    add_column :region_versions, :population, :integer
  end

  def self.down
    remove_column :regions, :population
    remove_column :region_versions, :population
  end
end
