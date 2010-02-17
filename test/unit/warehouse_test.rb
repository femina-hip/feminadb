require File.dirname(__FILE__) + '/../test_helper'

class WarehouseTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = true
  fixtures :warehouses, :delivery_methods, :warehouse_issue_box_sizes, :issues, :issue_box_sizes

  # Cannot delete if delivery method depends on it
  def test_protected_by_delivery_method
    assert_raise(ActiveRecord::ReferentialIntegrityProtectionError) { @w2.destroy }

    DeliveryMethod.delete(@dm2.id)
    assert_nothing_raised(ActiveRecord::ReferentialIntegrityProtectionError) { @w2.destroy }
  end

  def test_destroys_warehouse_issue_box_sizes
    DeliveryMethod.delete(@dm1.id)
    DeliveryMethod.delete(@dm3.id)
    @w1.destroy

    assert_raise(ActiveRecord::RecordNotFound) { WarehouseIssueBoxSize.find(1) }
  end

  def test_num_copies
    assert_equal 50, warehouses(:w1).num_copies(issues(:issue1))
  end

  def test_num_copies_when_no_issue_box_sizes
    assert_equal 0, warehouses(:w2).num_copies(issues(:issue1))
  end

  def test_num_copies_when_no_warehouse_issue_box_sizes
    WarehouseIssueBoxSize.delete_all
    assert_equal 0, warehouses(:w1).num_copies(issues(:issue1))
  end
end
