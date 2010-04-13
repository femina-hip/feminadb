class Publication < ActiveRecord::Base
  include SoftDeletable
  versioned
  acts_as_reportable

  has_many :issues,
           :order => :issue_number,
           :dependent => :restrict,
           :conditions => 'issues.deleted_at IS NULL'
  has_many :standing_orders,
           :dependent => :destroy,
           :conditions => 'standing_orders.deleted_at IS NULL'
  has_many :customers,
           :through => :standing_orders,
           :include => :region,
           :order => 'regions.name, customers.district, customers.name',
           :conditions => 'customers.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :tracking_standing_orders,
        :conditions => { :tracks_standing_orders => true }
end
