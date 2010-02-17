require File.dirname(__FILE__) + '/../test_helper'

class DeliveryMethodTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = true
  fixtures :delivery_methods, :standing_orders, :orders

  # Cannot delete if orders depend on it
  def test_protects_orders
    Customer.delete_all
    assert_raise(ActiveRecord::ReferentialIntegrityProtectionError) { @dm1.destroy }
    Order.delete_all
    assert_nothing_raised(ActiveRecord::ReferentialIntegrityProtectionError) { @dm1.destroy }
  end

  # Cannot delete if customers depend on it
  def test_protects_customers
    Order.delete_all
    assert_raise(ActiveRecord::ReferentialIntegrityProtectionError) { @dm1.destroy }
    Customer.delete_all
    assert_nothing_raised(ActiveRecord::ReferentialIntegrityProtectionError) { @dm1.destroy }
  end
end
