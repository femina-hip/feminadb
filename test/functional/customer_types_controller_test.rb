require File.dirname(__FILE__) + '/../test_helper'

class CustomerTypesControllerTest < ActionController::TestCase
  fixtures :customer_types, :users, :roles, :roles_users

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:customer_types)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_customer_type
    login_as :admin
    old_count = CustomerType.count
    post :create, :customer_type => { :name => 'T', :description => 'Test', :category => 'Unknown' }
    assert_equal old_count+1, CustomerType.count
    
    assert_redirected_to admin_customer_type_path(assigns(:customer_type))
  end

  def test_should_show_customer_type
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_customer_type
    login_as :admin
    put :update, :id => 1, :customer_type => { :name => 'T', :description => 'Test', :category => 'Unknown' }
    assert_redirected_to admin_customer_type_path(assigns(:customer_type))
  end
  
  def test_should_destroy_customer_type
    login_as :admin
    old_count = CustomerType.count
    delete :destroy, :id => 3
    assert_equal old_count-1, CustomerType.count
    
    assert_redirected_to admin_customer_types_path
  end

  def test_should_not_destroy_used_customer_type
    login_as :admin
    old_count = CustomerType.count
    delete :destroy, :id => 2
    assert_equal old_count, CustomerType.count
    
    assert_redirected_to admin_customer_types_path
  end
end
