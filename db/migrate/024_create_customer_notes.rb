class CreateCustomerNotes < ActiveRecord::Migration
  def self.up
    create_table :customer_notes do |t|
      t.column :customer_id, :int
      t.column :note, :text
      t.column :created_at, :datetime
      t.column :created_by, :integer
      t.column :deleted_at, :datetime
    end
  end

  def self.down
    drop_table :customer_notes
  end
end
