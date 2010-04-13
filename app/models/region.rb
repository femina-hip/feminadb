class Region < ActiveRecord::Base
  include SoftDeletable
  versioned
  acts_as_reportable

  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
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
  validates_uniqueness_of :name
end
