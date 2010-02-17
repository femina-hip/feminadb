require File.dirname(__FILE__) + '/../test_helper'

class WarehousesControllerTest < ActionController::TestCase
  fixtures :warehouses, :users, :roles, :roles_users

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:warehouses)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_warehouse
    login_as :admin
    old_count = Warehouse.count
    post :create, :warehouse => { :name => 'TestCreate', :comment => 'work!' }
    assert_equal old_count+1, Warehouse.count
    
    assert_redirected_to admin_warehouse_path(assigns(:warehouse))
  end

  def test_should_show_warehouse
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_warehouse
    login_as :admin
    put :update, :id => 1, :warehouse => { :name => 'TestUpdate', :comment => 'work!' }
    assert_redirected_to admin_warehouse_path(assigns(:warehouse))
  end
  
  def test_should_destroy_warehouse
    login_as :admin
    old_count = Warehouse.count
    delete :destroy, :id => 3
    assert_equal old_count-1, Warehouse.count
    
    assert_redirected_to admin_warehouses_path
  end

  def test_should_not_destroy_used_warehouse
    login_as :admin
    old_count = Warehouse.count
    delete :destroy, :id => 2
    assert_equal old_count, Warehouse.count
    
    assert_redirected_to admin_warehouses_path
  end
end
