class UpdatedByOnSpecialOrderLinesNotRequired < ActiveRecord::Migration
  def self.up
    change_column :special_order_lines, :updated_by, :integer, :null => true
  end

  def self.down
    change_column :special_order_lines, :updated_by, :integer, :null => false
  end
end
