class ResizeBlobTo2mb < ActiveRecord::Migration
  def self.up
    change_column :blobs, :data, :binary, :limit => 2.megabytes, :null => false
    change_column :blob_versions, :data, :binary, :limit => 2.megabytes, :null => false
  end

  def self.down
    change_column :blobs, :data, :binary, :null => false
    change_column :blob_versions, :data, :binary, :null => false
  end
end
