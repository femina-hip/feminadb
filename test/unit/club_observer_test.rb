require File.dirname(__FILE__) + '/../test_helper'

class ClubObserverTest < Test::Unit::TestCase
  fixtures :customers, :clubs

  # Replace this with your real tests.
  def test_truth
    Customer.any_instance.expects(:ferret_update)
    customers(:customer1).club.update_attributes :name => 'New name'
  end
end
