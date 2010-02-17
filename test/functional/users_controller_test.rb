require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users, :roles, :roles_users

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:users)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_user
    login_as :admin
    old_count = User.count
    post :create, :user => { :login => 'create_test', :email => 'create@test.com', :password => 'test', :password_confirmation => 'test' }
    assert_equal old_count+1, User.count
    
    assert_redirected_to admin_user_path(assigns(:user))
  end

  def test_should_show_user
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_user
    login_as :admin
    put :update, :id => 1, :user => { :login => 'update_test', :email => 'create@test.com', :password => 'test', :password_confirmation => 'test' }
    assert_redirected_to admin_user_path(assigns(:user))
  end

  def test_should_not_update_empty_password
    login_as :admin
    put :update, :id => 1, :user => { :login => 'update_test', :email => 'create@test.com' }
    assert_redirected_to admin_user_path(assigns(:user))
    assert_equal true, users(:quentin).authenticated?('test')
  end

  def test_should_update_password
    login_as :admin
    put :update, :id => 1, :user => { :password => 'test2', :password_confirmation => 'test2' }
    assert_redirected_to admin_user_path(assigns(:user))
    assert_equal true, users(:quentin).authenticated?('test2')
  end
  
  def test_should_destroy_user
    login_as :admin
    old_count = User.count
    delete :destroy, :id => 1
    assert_equal old_count-1, User.count
    
    assert_redirected_to admin_users_path
  end
end
