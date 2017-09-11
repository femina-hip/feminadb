class SimplifyOrderDeliveryContact < ActiveRecord::Migration[4.2]
  def change
    rename_column(:orders, :contact_details, :delivery_contact)
  end
end
