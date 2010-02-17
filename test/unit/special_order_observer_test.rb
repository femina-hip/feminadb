require File.dirname(__FILE__) + '/../test_helper'

class SpecialOrderObserverTest < Test::Unit::TestCase
  fixtures :special_orders, :special_order_lines, :users, :issues, :publications

  def setup
    User.current_user = users(:admin)
  end

  # Replace this with your real tests.
  def test_create
    dt = DateTime.parse "2008-01-23T13:44:02+03:00"

    n = SpecialOrder.new(
      :requested_by => 3,
      :customer_name => 'Test',
      :reason => 'Test',
      :requested_at => dt,
      :requested_for_date => dt.to_date
    )
    n.lines.build(:issue_id => 1, :num_copies_requested => 10)

    SpecialOrderObserver.any_instance.expects(:do_send).with(:special_order_created, n).once
    n.save!
  end

  def test_approve
    special_orders(:one).approve
    special_orders(:one).lines.first.num_copies = 1
    special_orders(:one).lines.first.save!

    SpecialOrderObserver.any_instance.expects(:do_send).with(:special_order_approved, special_orders(:one)).once
    special_orders(:one).save!
  end

  def test_deny
    special_orders(:one).deny

    SpecialOrderObserver.any_instance.expects(:do_send).with(:special_order_denied, special_orders(:one)).once
    special_orders(:one).save!
  end
end
