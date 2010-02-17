class CreateBlobs < ActiveRecord::Migration
  def self.up
    create_table :blobs do |t|
      t.column :name, :string, :null => false
      t.column :data, :binary, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :updated_by, :string, :null => false
      t.column :version, :int, :null => false
      t.column :deleted_at, :datetime
    end
    Blob.create_versioned_table
  end

  def self.down
    Blob.drop_versioned_table
    drop_table :blobs
  end
end
