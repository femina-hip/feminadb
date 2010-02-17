require File.dirname(__FILE__) + '/../test_helper'

class IssueDistrictBreakdownControllerTest < ActionController::TestCase
  fixtures :issues, :regions, :publications, :customers, :orders

  def test_index
    get :index, :publication_id => 1
    assert_response :success
  end

  def test_orders
    get :orders, :publication_id => 1, :issue_id => 2, :region_id => 1, :district => 'req12'
    assert_response :success
    assert assigns(:orders).length > 0
  end
end
