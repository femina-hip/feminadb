require File.dirname(__FILE__) + '/../test_helper'

class CustomerNotesControllerTest < ActionController::TestCase
  fixtures :customers, :customer_notes, :users, :roles, :roles_users

  def test_new
    login_as :admin
    get :new, :customer_id => 1
    assert_response :success
  end
end
