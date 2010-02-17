require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class StandingOrderTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = true
  fixtures :standing_orders, :orders, :issues, :customers

  def test_create_order_for_issue!
    now = DateTime.now
    DateTime.stubs(:now).returns(now)
    req1 = @s11.create_order_for_issue!(@issue1)
    assert_equal now, req1.order_date
    assert_equal 'Automatic from Standing Order', req1.comments
    assert_equal @s11.num_copies, req1.num_copies
    assert_equal @s11.customer_id, req1.customer_id
    assert_equal @issue1.id, req1.issue_id
    assert_equal @s11.customer.name, req1.customer_name
    assert_equal @s11.customer.delivery_method_id, req1.delivery_method_id

    # Cannot make two orders for the same issue
    assert_raises(ActiveRecord::RecordInvalid) { @s11.create_order_for_issue!(@issue2) }
  end

  def test_can_create_with_publication_tracking_special_orders
    s = StandingOrder.new(:customer_id => 2, :publication_id => 2, :num_copies => 50)
    assert_valid s
  end

  def test_cannot_create_without_publication_tracking_special_orders
    s = StandingOrder.new(:customer_id => 1, :publication_id => 3, :num_copies => 50)
    assert !s.valid?
  end
end
