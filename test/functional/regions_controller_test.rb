require File.dirname(__FILE__) + '/../test_helper'

class RegionsControllerTest < ActionController::TestCase
  fixtures :regions, :users, :roles, :roles_users

  def test_should_get_index
    login_as :admin
    get :index
    assert_response :success
    assert assigns(:regions)
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_create_region
    login_as :admin
    old_count = Region.count
    post :create, :region => { :name => 'Created Region' }
    assert_equal old_count+1, Region.count
    
    assert_redirected_to admin_region_path(assigns(:region))
  end

  def test_should_show_region
    login_as :admin
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_region
    login_as :admin
    put :update, :id => 1, :region => { :name => 'Updated Region' }
    assert_redirected_to admin_region_path(assigns(:region))
  end
  
  def test_should_destroy_region
    login_as :admin
    old_count = Region.count
    delete :destroy, :id => 3
    assert_equal old_count-1, Region.count
    
    assert_redirected_to admin_regions_path
  end

  def test_should_not_destroy_used_region
    login_as :admin
    old_count = Region.count
    delete :destroy, :id => 2
    assert_equal old_count, Region.count
    
    assert_redirected_to admin_regions_path
  end
end
