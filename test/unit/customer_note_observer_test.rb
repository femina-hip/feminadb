require File.dirname(__FILE__) + '/../test_helper'

class CustomerNoteObserverTest < Test::Unit::TestCase
  fixtures :customers, :customer_notes, :tags

  def test_create_calls_ferret_update
    Customer.any_instance.expects(:ferret_update)
    customers(:customer1).notes.create!(:note => 'Hi There')
  end

  def test_destroy_calls_ferret_update
    Customer.any_instance.expects(:ferret_update)
    customer_notes(:cn11).destroy
  end

  def test_adds_tag
    customers(:customer1).notes.create!(:note => 'TAG_WHEEBOP')
    new_tag = Tag.find_by_name('WHEEBOP')
    assert_not_nil new_tag
    assert_equal 1, new_tag.num_customers
  end

  def test_removes_tag
    customer_notes(:tag).destroy
    old_tag = Tag.find_by_name('TESTING')
    assert_nil old_tag
  end

  def test_increments_tag
    customers(:customer1).notes.create!(:note => 'TAG_TESTING')
    tag = Tag.find_by_name('TESTING')
    assert_not_nil tag
    assert_equal 2, tag.num_customers
  end

  def test_decrements_tag
    customers(:customer1).notes.create!(:note => 'TAG_TESTING')
    customer_notes(:tag).destroy!
    tag = Tag.find_by_name('TESTING')
    assert_not_nil tag
    assert_equal 1, tag.num_customers
  end
end
