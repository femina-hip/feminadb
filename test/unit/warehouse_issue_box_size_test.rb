require File.dirname(__FILE__) + '/../test_helper'

class WarehouseIssueBoxSizeTest < Test::Unit::TestCase
  fixtures :warehouses, :issues, :issue_box_sizes, :warehouse_issue_box_sizes

  def test_num_copies
    assert_equal 10, warehouse_issue_box_sizes(:one).num_copies
    assert_equal 20*2, warehouse_issue_box_sizes(:two).num_copies
  end
end
