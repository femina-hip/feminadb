class MoveDeliveryMethodIdFromCustomersToRegions < ActiveRecord::Migration[5.1]
  def up
    add_column(:regions, :delivery_method_id, :integer)
    execute <<-EOT
      UPDATE regions
      SET delivery_method_id = COALESCE(
        (SELECT delivery_method_id FROM customers WHERE region_id = regions.id AND delivery_method_id NOT IN (SELECT id FROM delivery_methods WHERE abbreviation = 'OLD') GROUP BY delivery_method_id ORDER BY COUNT(*) DESC LIMIT 1),
        (SELECT id FROM delivery_methods WHERE abbreviation = 'FEMINA'),
        (SELECT id FROM delivery_methods LIMIT 1)
      )
    EOT
    change_column(:regions, :delivery_method_id, :integer, null: false)
    remove_column(:customers, :delivery_method_id)
  end
end
