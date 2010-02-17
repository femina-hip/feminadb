class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts do |t|
      t.column :region_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :color, :string, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :updated_by, :string, :null => false
      t.column :version, :int, :null => false
      t.column :deleted_at, :datetime
    end
    District.create_versioned_table
  end

  def self.down
    District.drop_versioned_table
    drop_table :districts
  end
end
