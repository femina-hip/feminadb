require File.dirname(__FILE__) + '/../test_helper'

class WarehouseTest < ActiveSupport::TestCase
  fixtures :warehouses, :delivery_methods, :warehouse_issue_box_sizes, :issues, :issue_box_sizes

  # Cannot delete if delivery method depends on it
  test 'cannot delete Warehouse if DeliveryMethod depends on it' do
    Order.delete_all
    Customer.delete_all

    assert_raise(ActiveRecord::ReferentialIntegrityProtectionError) { warehouses(:w2).destroy }

    delivery_methods(:dm2).destroy
    assert_nothing_raised(ActiveRecord::ReferentialIntegrityProtectionError) { warehouses(:w2).destroy }
  end

  test 'destroying Warehouse destroys WarehouseIssueBoxSizes' do
    Order.delete_all
    Customer.delete_all
    delivery_methods(:dm1).destroy
    delivery_methods(:dm3).destroy
    warehouses(:w1).destroy

    assert_raise(ActiveRecord::RecordNotFound) { WarehouseIssueBoxSize.find(1) }
  end

  test 'num_copies works' do
    assert_equal 50, warehouses(:w1).num_copies(issues(:issue1))
  end

  test 'num_copies works when there are no IssueBoxSizes' do
    assert_equal 0, warehouses(:w2).num_copies(issues(:issue1))
  end

  test 'num_copies works when there are no WarehouseIssueBoxSizes' do
    WarehouseIssueBoxSize.delete_all
    assert_equal 0, warehouses(:w1).num_copies(issues(:issue1))
  end
end
