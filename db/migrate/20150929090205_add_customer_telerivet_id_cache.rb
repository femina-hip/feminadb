class AddCustomerTelerivetIdCache < ActiveRecord::Migration[4.2]
  def change
    add_column :customers, :telerivet_id_cache, :text
  end
end
