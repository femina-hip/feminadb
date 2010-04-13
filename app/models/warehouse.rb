class Warehouse < ActiveRecord::Base
  has_many :warehouse_issue_box_sizes,
           :dependent => :destroy,
           :conditions => 'warehouse_issue_box_sizes.deleted_at IS NULL'
  has_many :issue_box_sizes,
           :through => :warehouse_issue_box_sizes,
           :conditions => 'issue_box_sizes.deleted_at IS NULL AND warehouse_issue_box_sizes.deleted_at IS NULL'
  has_many :issues,
           :through => :warehouse_issue_box_sizes,
           :conditions => 'issues.deleted_at IS NULL AND warehouse_issue_box_sizes.deleted_at IS NULL'
  has_many :delivery_methods,
           :dependent => :restrict,
           :conditions => 'delivery_methods.deleted_at IS NULL'

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :inventory, :conditions => { :tracks_inventory => true }

  def num_copies(issue)
    warehouse_issue_box_sizes.includes(:issue_box_size).where('issue_box_sizes.issue_id' => issue.id).inject(0){ |sum, wibs| sum + wibs.num_copies }
  end
end
