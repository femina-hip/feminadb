class CustomerNote < ActiveRecord::Base
  include SoftDeletable

  belongs_to :customer
  after_save { |note| note.customer.try(:index) }

  belongs_to :created_by_user, :class_name => 'User', :foreign_key => :created_by

  validates_presence_of :customer_id
  validates_length_of :note, :minimum => 5

  # We explicitly disallow editing Notes
  attr_readonly :created_by, :created_at, :customer_id, :note
end
