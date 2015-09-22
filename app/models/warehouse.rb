class Warehouse < ActiveRecord::Base
  has_many(:delivery_methods)
  #has_many :delivery_methods,
  #         :dependent => :restrict,
  #         :conditions => 'delivery_methods.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name
end
