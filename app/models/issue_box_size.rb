class IssueBoxSize < ActiveRecord::Base
  belongs_to(:issue)

  validates_presence_of :issue_id, :if => Proc.new { |ibs| not ibs.new_record? }
  validates_presence_of :num_copies
  validates_uniqueness_of :num_copies, :scope => :issue_id
end
