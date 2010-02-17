require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../mocks/test/backgroundrb_mock'
Messenger.sender_class = nil

class SpecialOrderTest < Test::Unit::TestCase
  fixtures :special_orders, :special_order_lines, :users

  def setup
    User.current_user = users(:quentin)
  end

  def test_approve
    so = special_orders(:one)
    assert_equal false, so.approved?
    assert_equal false, so.denied?
    assert_nil so.authorized_by
    so.approve
    assert so.approved?
    assert_equal false, so.denied?
    assert_equal 1, so.authorized_by
    assert_not_nil so.authorized_at
  end

  def test_cannot_approve_non_pending
    so = special_orders(:one)
    so.lines.first.num_copies = 1
    so.approve
    assert_valid so
    so.save!
    so.lines.first.save!

    so.reload
    assert_valid so
    so.approve
    assert (not so.valid?)
  end

  def test_cannot_deny_non_pending
    so = special_orders(:one)
    so.lines.first.num_copies = 1
    so.approve
    assert_valid so
    so.save!
    so.lines.first.save!

    so.reload
    assert_valid so
    so.deny
    assert (not so.valid?)
  end

  def test_deny
    so = special_orders(:one)
    assert_equal false, so.approved?
    assert_equal false, so.denied?
    assert_nil so.authorized_by
    so.deny
    assert_equal false, so.approved?
    assert so.denied?
    assert_equal 1, so.authorized_by
    assert_not_nil so.authorized_at
  end

  def test_not_allowed_empty
    so = SpecialOrder.new(:customer_name => 'Adam Hooper', :reason => 'Because', :requested_at => DateTime.parse('2007-12-10 10:02:00'), :requested_for_date => Date.parse('2007-12-10'))
    assert (not so.valid?)
    so.lines.build(:issue_id => 1, :num_copies_requested => 1)
    assert_valid so
  end

  def test_create
    so = SpecialOrder.new(:customer_name => 'Adam Hooper', :reason => 'Because', :requested_at => DateTime.parse('2007-12-10 10:02:00'), :requested_for_date => Date.parse('2007-12-10'))
    so.lines.build(:issue_id => 1, :num_copies_requested => 1)
    assert_nothing_raised { so.save! }
  end

  def test_cannot_create_with_zero_copies
    so = SpecialOrder.new(:customer_name => 'Adam Hooper', :reason => 'Because', :requested_at => DateTime.parse('2007-12-10 10:02:00'), :requested_for_date => Date.parse('2007-12-10'))
    so.lines.build(:issue_id => 1, :num_copies_requested => 0)
    assert_equal false, so.valid?
  end

  def test_cannot_approve_with_zero_copies
    so = special_orders(:one)
    so.approve
    assert (not so.valid?)
    so.lines.first.num_copies = 1
    assert_valid so
  end

  def test_can_approve_with_negative_copies
    so = special_orders(:one)
    so.approve
    assert (not so.valid?)
    so.lines.first.num_copies = -1
    assert_valid so
  end

  def test_pending_avoids_approved
    assert_equal 2, SpecialOrder.find_pending(:all).length
    so = special_orders(:one)
    so.lines.first.num_copies = 1
    so.approve
    so.save!
    assert_equal 1, SpecialOrder.find_pending(:all).length
  end

  def test_pending_avoids_denied
    assert_equal 2, SpecialOrder.find_pending(:all).length
    so = special_orders(:one)
    so.lines.first.num_copies = 1
    so.deny
    so.save!
    assert_equal 1, SpecialOrder.find_pending(:all).length
  end

  def test_denied
    so = special_orders(:one)
    assert_equal false, so.denied?
    so.deny
    assert so.denied?
  end

  def test_approved
    so = special_orders(:one)
    assert_equal false, so.approved?
    so.approve
    assert so.approved?
  end

  def test_completed_scope
    assert_equal 0, SpecialOrder.calculate_completed(:count, :all)
    ensure_approved!(special_orders(:one))
    special_orders(:one).complete
    special_orders(:one).save!
    assert_equal 1, SpecialOrder.calculate_completed(:count, :all)
  end

  def test_pending_scope
    assert_equal 2, SpecialOrder.calculate_pending(:count, :all)
    ensure_approved!(special_orders(:one))
    assert_equal 1, SpecialOrder.calculate_pending(:count, :all)
  end

  def test_approved_scope
    assert_equal 0, SpecialOrder.calculate_approved(:count, :all)
    ensure_approved!(special_orders(:one))
    assert_equal 1, SpecialOrder.calculate_approved(:count, :all)
  end

  def test_denied_scope
    assert_equal 0, SpecialOrder.calculate_denied(:count, :all)
    so = special_orders(:one)
    so.deny
    so.save!
    assert_equal 1, SpecialOrder.calculate_denied(:count, :all)
  end

  def test_incomplete_approved_scope
    assert_equal 0, SpecialOrder.calculate_incomplete_approved(:count, :all)
    ensure_approved!(special_orders(:one))
    assert_equal 1, SpecialOrder.calculate_incomplete_approved(:count, :all)
    special_orders(:one).complete
    special_orders(:one).save!
    assert_equal 0, SpecialOrder.calculate_incomplete_approved(:count, :all)
  end

  def test_cannot_complete_without_approval
    so = special_orders(:one)
    assert so.valid?
    so.complete
    assert_equal false, so.valid?
  end

  def test_state_string
    so = special_orders(:one)
    assert_equal 'Pending', so.state_string
    so.approve
    assert_equal 'Approved', so.state_string
    so.complete
    assert_equal 'Completed', so.state_string

    so2 = special_orders(:two)
    assert_equal 'Pending', so2.state_string
    so2.deny
    assert_equal 'Denied', so2.state_string
  end

  private
    def ensure_approved!(special_order)
      special_order.lines.first.num_copies = 1
      special_order.approve
      special_order.save!
    end
end
