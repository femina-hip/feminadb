class SimplifyOrderDeliveryContact < ActiveRecord::Migration
  def change
    rename_column(:orders, :contact_details, :delivery_contact)
  end
end
