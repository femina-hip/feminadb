require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :orders, :customers, :regions, :delivery_methods

  def test_customer_data_copied
    r = Order.new(:issue_id => 1, :customer_id => 1, :order_date => Date.parse('2007-10-25'), :num_copies => 5)
    assert r.valid?
    assert_equal 1, r.region_id
    assert_equal 1, r.delivery_method_id
    assert_equal 'MyString', r.customer_name
  end

  def test_cannot_create_0_copy_test
    r = Order.new :issue_id => 1, :customer_id => 1, :order_date => Date.parse('2007-11-28'), :num_copies => 0
    assert_equal false, r.valid?
  end

  def test_cannot_create_nil_copies_test
    r = Order.new :issue_id => 1, :customer_id => 1, :order_date => Date.parse('2007-11-28'), :num_copies => nil
    assert_equal false, r.valid?
  end
end
