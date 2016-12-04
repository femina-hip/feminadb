class Region < ActiveRecord::Base
  has_many(:customers)
  has_many(:orders)

  #has_many :customers,
  #         :dependent => :restrict,
  #         :conditions => 'customers.deleted_at IS NULL'
  #has_many :orders,
  #         :include => { :issue => :publication },
  #         :dependent => :restrict,
  #         :conditions => 'orders.deleted_at IS NULL AND issues.deleted_at IS NULL AND publications.deleted_at IS NULL'
  #has_many :councils,
  #         :dependent => :destroy,
  #         :conditions => 'councils.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name

  def councils
    @councils ||= (councils_separated_by_newline || '')
      .split(/\r?\n/)
      .map(&:strip)
      .reject(&:empty?)
      .sort
  end
end
