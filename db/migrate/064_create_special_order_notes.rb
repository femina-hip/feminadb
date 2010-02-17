class CreateSpecialOrderNotes < ActiveRecord::Migration
  def self.up
    create_table :special_order_notes do |t|
      t.column :special_order_id, :integer, :null => false
      t.column :note, :text, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :created_by, :integer
      t.column :deleted_at, :datetime
    end
    add_index :special_order_notes, :special_order_id
  end

  def self.down
    drop_table :special_order_notes
  end
end
