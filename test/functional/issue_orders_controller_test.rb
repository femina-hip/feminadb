require File.dirname(__FILE__) + '/../test_helper'

class IssueOrdersControllerTest < ActionController::TestCase
  fixtures :customers, :regions, :delivery_methods, :issues, :publications, :orders, :users, :roles, :roles_users

  def test_index
    get :index, { :publication_id => 1, :issue_id => 1 }
    assert_response :success
  end

  def test_index_as_admin
    login_as :admin
    get :index, { :publication_id => 1, :issue_id => 1 }
    assert_response :success
  end
end
