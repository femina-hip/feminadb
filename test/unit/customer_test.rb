require File.dirname(__FILE__) + '/../test_helper'

class CustomerTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = true
  fixtures :regions, :customer_types, :delivery_methods, :customers, :publications

  def test_crud
    cust = Customer.new(
        :region_id => @region1.id,
        :customer_type_id => @ct1.id,
        :name => 'New Customer',
        :district => 'District',
        :delivery_method_id => @dm1.id)
    assert cust.save
    cust2 = Customer.find(cust.id)
    assert_equal cust, cust2
    cust2.name = cust2.name.reverse
    assert cust2.save
    assert cust2.destroy
  end

  def test_deleted_orders_hidden
    c = customers(:customer3)
    r = c.orders.create!(:issue_id => 1, :num_copies => 5, :delivery_method_id => 1, :region_id => c.region_id)
    assert_equal 1, Customer.find(c.id).orders.length
    r.destroy
    assert_equal 0, Customer.find(c.id).orders.length
  end

  def test_deleted_standing_orders_hidden
    c = customers(:customer3)
    s = c.standing_orders.create!(:publication_id => 1, :num_copies => 5)
    assert_equal 1, Customer.find(c.id).standing_orders.length
    s.destroy
    assert_equal 0, Customer.find(c.id).standing_orders.length
  end

  def test_deliver_via_string
    c = Customer.new(:name => 'Test', :region_id => 1, :district => 'District', :delivery_method_id => 2, :customer_type_id => 1)
    assert_valid c
    assert_equal nil, c.deliver_via_string
    c.deliver_via = c.name
    assert_equal nil, c.deliver_via_string
    assert_valid c # Will clear c.deliver_via
    assert_equal nil, c.deliver_via
    assert_equal nil, c.deliver_via_string
    c.deliver_via = 'hi'
    assert_equal 'via hi', c.deliver_via_string
    assert_valid c
    assert_equal 'via hi', c.deliver_via_string
  end
end
