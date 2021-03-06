class DeliveryMethod < ActiveRecord::Base
  has_many(:orders)
  has_many(:regions)

  #has_many :orders,
  #         :include => { :issue => :publication },
  #         :dependent => :restrict,
  #         :conditions => 'orders.deleted_at IS NULL AND issues.deleted_at IS NULL AND publications.deleted_at IS NULL'
  #has_many :customers,
  #         :dependent => :restrict,
  #         :conditions => 'customers.deleted_at IS NULL'

  validates_presence_of :abbreviation
  validates_uniqueness_of :abbreviation
  validates_presence_of :name
  validates_uniqueness_of :name

  def full_name
    "#{abbreviation}: #{name}"
  end
end
