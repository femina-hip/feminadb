class IssueBoxSize < ActiveRecord::Base
  acts_as_paranoid
  versioned
  acts_as_reportable

  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  belongs_to :issue
  has_many :warehouse_issue_box_sizes,
           :dependent => :destroy,
           :conditions => 'warehouse_issue_box_sizes.deleted_at IS NULL'

  validates_presence_of :issue_id,
                        :if => Proc.new { |ibs| not ibs.new_record? }
  validates_presence_of :num_copies
  validates_uniqueness_of :num_copies, :scope => :issue_id
end
