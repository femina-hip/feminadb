class AddPackingHints < ActiveRecord::Migration
  def self.up
    add_column(:publications, :packing_hints, :string)
    add_column(:issues, :packing_hints, :string)
  end

  def self.down
    remove_column(:publications, :packing_hints, :string)
    remove_column(:issues, :packing_hints, :string)
  end
end
