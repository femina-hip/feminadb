class AddOrderHeadmasterSmsNumbers < ActiveRecord::Migration[5.1]
  def change
    add_column(:orders, :headmaster_sms_numbers, :string)
  end
end
