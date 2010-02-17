class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.column :name, :string
      t.column :updated_at, :datetime
      t.column :updated_by, :int
      t.column :version, :int
    end
    Region.create_versioned_table
  end

  def self.down
    Region.drop_versioned_table
    drop_table :regions
  end
end
