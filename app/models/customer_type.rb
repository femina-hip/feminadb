class CustomerType < ActiveRecord::Base
  # acts_as_paranoid
  versioned
  acts_as_reportable

  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  has_many :customers,
           :dependent => :protect,
           :conditions => 'customers.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description
  validates_uniqueness_of :description
  validates_presence_of :category
end
