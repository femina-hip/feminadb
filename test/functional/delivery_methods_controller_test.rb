require File.dirname(__FILE__) + '/../test_helper'

class DeliveryMethodsControllerTest < ActionController::TestCase
  fixtures :delivery_methods, :users, :roles, :roles_users, :orders, :customers

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:delivery_methods)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_delivery_method
    login_as :admin
    old_count = DeliveryMethod.count
    post :create, :delivery_method => { :abbreviation => 'ABC', :name => 'Amabilis', :description => 'Creation inspired for a certain editor' }
    assert_equal old_count+1, DeliveryMethod.count
    
    assert_redirected_to admin_delivery_method_path(assigns(:delivery_method))
  end

  def test_should_show_delivery_method
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_delivery_method
    login_as :admin
    put :update, :id => 1, :delivery_method => { :abbreviation => 'ABC', :name => 'Amabilis', :description => 'Delivered to a certain editor' }
    assert_redirected_to admin_delivery_method_path(assigns(:delivery_method))
  end
  
  def test_should_destroy_delivery_method
    login_as :admin
    old_count = DeliveryMethod.count
    delete :destroy, :id => 3
    assert_equal old_count-1, DeliveryMethod.count
    
    assert_redirected_to admin_delivery_methods_path
  end

  def test_should_not_destroy_used_delivery_method
    login_as :admin
    old_count = DeliveryMethod.count
    delete :destroy, :id => 1
    assert_equal old_count, DeliveryMethod.count
  end
end
