class Region < ActiveRecord::Base
  include SoftDeletable
  versioned

  has_many :customers,
           :dependent => :restrict,
           :conditions => 'customers.deleted_at IS NULL'
  has_many :orders,
           :dependent => :restrict,
           :conditions => 'orders.deleted_at IS NULL'
  has_many :districts,
           :dependent => :destroy,
           :conditions => 'districts.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :deleted_at, :if => lambda { |r| r.deleted_at.nil? }
end
