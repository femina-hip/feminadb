class DeliveryMethod < ActiveRecord::Base
  include SoftDeletable

  belongs_to :warehouse
  has_many :orders,
           :dependent => :restrict,
           :conditions => 'orders.deleted_at IS NULL'
  has_many :customers,
           :dependent => :restrict,
           :conditions => 'customers.deleted_at IS NULL'

  validates_presence_of :abbreviation
  validates_uniqueness_of :abbreviation
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :warehouse_id
  validates_associated :warehouse

  def full_name
    "#{abbreviation}: #{name} (#{description})"
  end

  def include_in_distribution_quote_request?
    include_in_distribution_quote_request
  end
end
