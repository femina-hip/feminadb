class DropBlobs < ActiveRecord::Migration
  def self.up
    drop_table :blobs
    drop_table :blob_versions
  end

  def self.down
    create_table "blobs", :force => true do |t|
      t.string   "name",       :default => "", :null => false
      t.binary   "data",       :default => "", :null => false
      t.datetime "updated_at",                 :null => false
      t.string   "updated_by", :default => "", :null => false
      t.integer  "version",                    :null => false
      t.datetime "deleted_at"
    end
    create_table "blob_versions", :force => true do |t|
      t.integer  "blob_id"
      t.integer  "version"
      t.string   "name",       :default => ""
      t.binary   "data",       :default => "", :null => false
      t.datetime "updated_at"
      t.string   "updated_by", :default => ""
      t.datetime "deleted_at"
    end
  end
end
