class CreateCustomerNotesCustomerIdIndex < ActiveRecord::Migration
  def self.up
    add_index :customer_notes, :customer_id
  end

  def self.down
    remove_index :customer_notes, :customer_id
  end
end
