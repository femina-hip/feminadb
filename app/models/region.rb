class Region < ActiveRecord::Base
  acts_as_paranoid_versioned
  acts_as_reportable

  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  has_many :customers,
           :dependent => :protect,
           :conditions => 'customers.deleted_at IS NULL'
  has_many :orders,
           :dependent => :protect,
           :conditions => 'orders.deleted_at IS NULL'
  has_many :districts,
           :dependent => :destroy,
           :conditions => 'districts.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name
end
