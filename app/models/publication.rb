class Publication < ActiveRecord::Base
  include SoftDeletable
  versioned

  has_many :issues,
           :order => 'issues.issue_date DESC',
           :dependent => :restrict,
           :conditions => 'issues.deleted_at IS NULL'
  has_many :standing_orders,
           :dependent => :destroy,
           :conditions => 'standing_orders.deleted_at IS NULL'
  has_many :waiting_orders,
           :dependent => :destroy,
           :conditions => 'waiting_orders.deleted_at IS NULL'
  has_many :customers,
           :through => :standing_orders,
           :include => :region,
           :order => 'regions.name, customers.district, customers.name',
           :conditions => 'customers.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :deleted_at, :if => lambda { |p| p.deleted_at.nil? }

  scope :tracking_standing_orders,
        :conditions => { :tracks_standing_orders => true }

  scope :current_periodicals,
        :conditions => { :tracks_standing_orders => true, :deleted_at => nil },
        :order => :name

  scope :not_pr_material,
        :conditions => { :pr_material => false, :deleted_at => nil },
        :order => [ 'publications.tracks_standing_orders DESC, publications.name' ]
end
