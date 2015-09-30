class ChangeCustomerSmsFields < ActiveRecord::Migration
  def up
    rename_column(:customers, :other_contacts, :delivery_contact)
    rename_column(:customers, :sms_numbers, :primary_contact_sms_numbers)
    add_column(:customers, :headmaster_sms_numbers, :string)
    remove_column(:customers, :old_club_sms_numbers)
  end

  def down
    add_column(:customers, :old_club_sms_numbers, :string)
    remove_column(:customers, :headmaster_sms_numbers)
    rename_column(:customers, :primary_contact_sms_numbers, :sms_numbers)
    rename_column(:customers, :delivery_contact, :other_contacts)
  end
end
