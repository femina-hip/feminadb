require File.dirname(__FILE__) + '/../test_helper'

class SpecialOrderLineTest < ActiveSupport::TestCase
  fixtures :special_order_lines, :special_orders, :issues, :publications, :users

  def test_allows_positive_requested
    sol = SpecialOrderLine.new(:special_order_id => 1, :issue_id => 1, :num_copies_requested => 1)
    assert_valid sol
  end

  def test_allows_negative_requested
    sol = SpecialOrderLine.new(:special_order_id => 1, :issue_id => 1, :num_copies_requested => -1)
    assert_valid sol
  end

  def test_does_not_allow_0_requested
    sol = SpecialOrderLine.new(:special_order_id => 1, :issue_id => 1, :num_copies_requested => 0)
    assert !sol.valid?
  end

  def test_does_not_allow_new_when_issue_not_allowed
    User.current_user = users(:admin)
    issue = Issue.create!(:name => 'test', :publication_id => 1, :issue_number => 15, :issue_date => Date.parse('2008-01-28'), :allows_new_special_orders => false)
    sol = SpecialOrderLine.new(:special_order_id => 1, :issue_id => issue.id, :num_copies_requested => 1)
    assert !sol.valid?
  end

  def test_allows_editing_when_issue_not_allowed
    User.current_user = users(:admin)
    issue = Issue.create!(:name => 'test', :publication_id => 1, :issue_number => 15, :issue_date => Date.parse('2008-01-28'), :allows_new_special_orders => true)
    sol = SpecialOrderLine.create!(:special_order_id => 1, :issue_id => issue.id, :num_copies_requested => 1)
    assert_valid sol
    issue.allows_new_special_orders = false
    issue.save!
    sol.reload
    assert_valid sol
    sol.num_copies_requested = 2
    assert_valid sol
  end
end
