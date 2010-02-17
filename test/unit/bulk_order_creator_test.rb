require File.dirname(__FILE__) + '/../test_helper'

class BulkOrderCreatorTest < Test::Unit::TestCase
  fixtures :customers, :standing_orders, :orders, :clubs, :delivery_methods, :regions, :customer_types, :issues, :publications # because of Search

  def test_find_customers_from_publication_id
    cs = BulkOrderCreator.find_customers_from_publication_id(1, '')
    assert_equal [ 1, 2 ], cs.collect(&:id).sort
  end

  def test_find_customers_from_publication_id_with_search
    cs = BulkOrderCreator.find_customers_from_publication_id(1, 'district:DistrictFive')
    assert_equal [ 2 ], cs.collect(&:id)
  end

  def test_find_customers_from_issue_id
    cs = BulkOrderCreator.find_customers_from_issue_id(2, '')
    assert_equal [ 1, 2 ], cs.collect(&:id).sort
  end

  def test_find_customers_from_issue_id_with_search
    cs = BulkOrderCreator.find_customers_from_issue_id(2, 'district:DistrictFive')
    assert_equal [ 2 ], cs.collect(&:id)
  end

  def test_find_customers
    cs = BulkOrderCreator.find_customers('name:*')
    assert_equal [ 1, 2, 3 ], cs.collect(&:id).sort
  end

  def test_find_customers_with_search
    cs = BulkOrderCreator.find_customers('district:DistrictFive')
    assert_equal [ 2 ], cs.collect(&:id)
  end

  def test_create_order!
    o = BulkOrderCreator.create_order!(
      customers(:customer1),
      1,
      50,
      :order_date => DateTime.parse('Tue, 05 Feb 2008 12:12:37 +0300')
    )
    assert_valid o
  end

  def test_do_copy_from_customers
    orders = BulkOrderCreator.do_copy_from_customers(:issue_id => 3, :q => '', :num_copies => 50)
    assert_equal 3, orders.length
    assert_equal [ 50, 50, 50 ], orders.collect(&:num_copies)
  end

  def test_do_copy_from_publication
    orders = BulkOrderCreator.do_copy_from_publication(:issue_id => 3, :q => '', :from_publication_id => 1)
    assert_equal 2, orders.length
    assert_equal [ 1, 2 ], orders.collect(&:customer_id).sort
    assert_equal [ 50, 100 ], orders.collect(&:num_copies).sort
  end

  def test_do_copy_from_issue
    orders = BulkOrderCreator.do_copy_from_issue(:issue_id => 3, :q => '', :from_issue_id => 2)
    assert_equal 2, orders.length
    assert_equal [ 1, 2 ], orders.collect(&:customer_id).sort
    assert_equal [ 50, 100 ], orders.collect(&:num_copies).sort
  end
end
