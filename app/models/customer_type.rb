class CustomerType < ActiveRecord::Base
  include SoftDeletable
  versioned

  has_many :customers,
           :dependent => :restrict,
           :conditions => 'customers.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name,
        :scope => :deleted_at, :if => lambda { |ct| ct.deleted_at.nil? }
  validates_presence_of :description
  validates_uniqueness_of :description,
        :scope => :deleted_at, :if => lambda { |ct| ct.deleted_at.nil? }
  validates_presence_of :category

  def full_name
    "#{name}: #{description}"
  end
end
