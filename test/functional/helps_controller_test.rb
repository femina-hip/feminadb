require File.dirname(__FILE__) + '/../test_helper'

class HelpsControllerTest < ActionController::TestCase
  def test_index
    assert_nothing_raised do
      get :index, :doc => 'index'
    end
  end
end
