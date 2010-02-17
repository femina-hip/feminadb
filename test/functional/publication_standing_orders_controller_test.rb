require File.dirname(__FILE__) + '/../test_helper'

class PublicationStandingOrdersControllerTest < ActionController::TestCase
  fixtures :customers, :regions, :delivery_methods, :standing_orders, :publications

  def test_index
    get :index, { :publication_id => 1 }
    assert_response :success
  end
end
