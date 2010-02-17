class ChangeCustomerTypeEmToDo < ActiveRecord::Migration
  def self.up
    CustomerType.enumeration_model_updates_permitted = true
    update "UPDATE customer_types SET name = 'DO', description = 'Donor Organization / Embassy' WHERE name = 'EM'"
  end

  def self.down
    CustomerType.enumeration_model_updates_permitted = true
    update "UPDATE customer_types SET name = 'EM', description = 'Embassy' WHERE name = 'DO'"
  end
end
