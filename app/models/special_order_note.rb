class SpecialOrderNote < ActiveRecord::Base
  acts_as_paranoid
  acts_as_reportable

  belongs_to :special_order
  belongs_to :created_by_user,
             :class_name => 'User',
             :foreign_key => :created_by

  validates_presence_of :special_order_id
  validates_length_of :note, :minimum => 5
end
