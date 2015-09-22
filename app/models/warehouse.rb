class Warehouse < ActiveRecord::Base
  has_many(:delivery_methods)

  validates_presence_of :name
  validates_uniqueness_of :name
end
