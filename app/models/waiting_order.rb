class WaitingOrder < ActiveRecord::Base
  acts_as_paranoid_versioned
  acts_as_reportable

  belongs_to :customer
  belongs_to :publication
  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by

  validates_presence_of :customer_id
  validates_presence_of :publication_id
  validates_presence_of :request_date
  validates_uniqueness_of :publication_id, :scope => :customer_id
  validates_inclusion_of :num_copies, :in => 1..9999999, :message => 'must be greater than 0'
end
