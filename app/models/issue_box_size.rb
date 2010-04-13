class IssueBoxSize < ActiveRecord::Base
  include SoftDeletable
  versioned
  acts_as_reportable

  belongs_to :issue
  has_many :warehouse_issue_box_sizes,
           :dependent => :destroy,
           :conditions => 'warehouse_issue_box_sizes.deleted_at IS NULL'

  validates_presence_of :issue_id,
                        :if => Proc.new { |ibs| not ibs.new_record? }
  validates_presence_of :num_copies
  validates_uniqueness_of :num_copies, :scope => [ :issue_id, :deleted_at ], :if => lambda { |id| id.deleted_at.nil? }
end
