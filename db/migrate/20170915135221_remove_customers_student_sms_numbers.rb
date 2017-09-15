class RemoveCustomersStudentSmsNumbers < ActiveRecord::Migration[5.1]
  def up
    remove_column(:customers, :student_sms_numbers)
  end
end
