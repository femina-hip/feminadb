require File.dirname(__FILE__) + '/../test_helper'

class PublicationsControllerTest < ActionController::TestCase
  fixtures :publications, :users, :roles, :roles_users

  def test_index
    get :index
    assert_response :success
  end

  def test_show
    get :show, :id => 1
    assert_redirected_to '/publications/1/issues'
  end

  def test_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_destroy_publication
    login_as :admin
    old_count = Publication.count
    delete :destroy, :id => 3
    assert_equal old_count-1, Publication.count
  end

  def test_should_not_destroy_used_publication
    login_as :admin
    old_count = Publication.count
    delete :destroy, :id => 1
    assert_equal old_count, Publication.count
  end
end
