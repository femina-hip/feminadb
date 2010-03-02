class CustomerNote < ActiveRecord::Base
  # acts_as_paranoid
  acts_as_reportable

  belongs_to :customer
  belongs_to :created_by_user, :class_name => 'User', :foreign_key => :created_by

  validates_presence_of :customer_id
  validates_length_of :note, :minimum => 5

  # We explicitly disallow editing Notes, because CustomerNotesObserver
  # cannot handle the tag editing. Users must delete the Note and create
  # a new one.
  attr_readonly :created_by, :created_at, :customer_id, :note
end
