class CreatePublications < ActiveRecord::Migration
  def self.up
    create_table :publications do |t|
      t.column :name, :string
      t.column :updated_at, :datetime
      t.column :updated_by, :string
      t.column :version, :int
    end
    Publication.create_versioned_table
  end

  def self.down
    Publication.drop_versioned_table
    drop_table :publications
  end
end
