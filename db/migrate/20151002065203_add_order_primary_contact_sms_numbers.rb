class AddOrderPrimaryContactSmsNumbers < ActiveRecord::Migration[4.2]
  def change
    add_column(:orders, :primary_contact_sms_numbers, :string)
  end
end
