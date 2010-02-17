require File.dirname(__FILE__) + '/../test_helper'

class WaitingOrderTest < ActiveSupport::TestCase
  fixtures :customers, :publications, :waiting_orders

  def test_can_create_with_publication_tracking_special_orders
    s = WaitingOrder.new(:customer_id => 2, :publication_id => 2, :num_copies => 50, :request_date => '2008-02-01')
    assert_valid s
  end

  def test_can_create_with_publication_not_tracking_special_orders
    s = WaitingOrder.new(:customer_id => 1, :publication_id => 3, :num_copies => 50, :request_date => '2008-02-01')
    assert_valid s
  end
end
