class CustomerType < ActiveRecord::Base
  has_many(:customers)

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description
  validates_uniqueness_of :description
  validates_presence_of :category

  def full_name
    "#{name}: #{description}"
  end
end
