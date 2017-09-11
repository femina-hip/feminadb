class RemoveDeliveryMethodDescription < ActiveRecord::Migration[5.1]
  def up
    remove_column(:delivery_methods, :description)
  end

  def down
    add_column(:delivery_methods, :description, :string)
  end
end
