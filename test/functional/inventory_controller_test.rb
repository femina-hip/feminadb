require File.dirname(__FILE__) + '/../test_helper'

class InventoryControllerTest < ActionController::TestCase
  fixtures :publications, :issues, :warehouses, :issue_box_sizes, :warehouse_issue_box_sizes

  def test_index
    assert_nothing_raised do
      get :index
    end
  end
end
