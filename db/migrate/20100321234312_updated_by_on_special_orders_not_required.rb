class UpdatedByOnSpecialOrdersNotRequired < ActiveRecord::Migration
  def self.up
    change_column :special_orders, :updated_by, :integer, :null => true
  end

  def self.down
    change_column :special_orders, :updated_by, :integer, :null => false
  end
end
