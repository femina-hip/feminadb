class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name, :null => false
      t.integer :num_customers, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :tags
  end
end
