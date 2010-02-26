class WarehouseIssueBoxSize < ActiveRecord::Base
  acts_as_paranoid
  versioned

  belongs_to :warehouse
  belongs_to :issue_box_size
  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by

  validates_presence_of :warehouse_id
  validates_presence_of :issue_box_size_id
  validates_uniqueness_of :issue_box_size_id, :scope => :warehouse_id

  def num_copies
    @num_copies = num_boxes * issue_box_size.num_copies
  end
end
