require File.dirname(__FILE__) + '/../test_helper'
require 'districts_controller'

class DistrictsControllerTest < ActionController::TestCase
  fixtures :districts, :regions, :users, :roles, :roles_users

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:districts)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_district
    login_as :admin
    old_count = District.count
    post :create, :district => { :region_id => 1, :name => 'TestCreate', :color => 'ffffff' }
    assert_equal old_count+1, District.count
    
    assert_redirected_to admin_district_path(assigns(:district))
  end

  def test_should_show_district
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_district
    login_as :admin
    put :update, :id => 1, :district => { :name => 'TestUpdate', :color => 'ffffff' }
    assert_redirected_to admin_district_path(assigns(:district))
  end
  
  def test_should_destroy_district
    login_as :admin
    old_count = District.count
    delete :destroy, :id => 1
    assert_equal old_count-1, District.count
    
    assert_redirected_to admin_districts_path
  end
end
