class AddCustomerTelerivetIdCache < ActiveRecord::Migration
  def change
    add_column :customers, :telerivet_id_cache, :text
  end
end
