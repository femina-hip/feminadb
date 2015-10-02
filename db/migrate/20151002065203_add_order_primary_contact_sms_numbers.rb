class AddOrderPrimaryContactSmsNumbers < ActiveRecord::Migration
  def change
    add_column(:orders, :primary_contact_sms_numbers, :string)
  end
end
