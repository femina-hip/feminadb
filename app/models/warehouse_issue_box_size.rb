class WarehouseIssueBoxSize < ActiveRecord::Base
  include SoftDeletable
  versioned

  belongs_to :warehouse
  belongs_to :issue_box_size

  validates_presence_of :warehouse_id
  validates_presence_of :issue_box_size_id
  validates_uniqueness_of :issue_box_size_id, :scope => [ :warehouse_id, :deleted_at ], :if => lambda { |wibs| wibs.deleted_at.nil? }

  def num_copies
    @num_copies = num_boxes * issue_box_size.num_copies
  end
end
