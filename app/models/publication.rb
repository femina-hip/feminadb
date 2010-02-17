class Publication < ActiveRecord::Base
  acts_as_paranoid_versioned
  acts_as_reportable

  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  has_many :issues,
           :order => :issue_number,
           :dependent => :protect,
           :conditions => 'issues.deleted_at IS NULL'
  has_many :standing_orders,
           :dependent => :destroy,
           :conditions => 'standing_orders.deleted_at IS NULL'
  has_and_belongs_to_many :customers,
                          :join_table => :standing_orders,
                          :include => :region,
                          :order => 'regions.name, customers.district, customers.name',
                          :conditions => 'customers.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name

  scope_out :tracking_standing_orders,
            :conditions => { :tracks_standing_orders => true }
end
