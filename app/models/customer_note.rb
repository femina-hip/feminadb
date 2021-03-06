class CustomerNote < ActiveRecord::Base
  belongs_to(:customer)
  belongs_to(:created_by_user, :class_name => 'User', :foreign_key => :created_by)

  after_save { |note| note.customer.try(:index) }

  validates_presence_of :customer_id
  validates_length_of :note, :minimum => 5
end
