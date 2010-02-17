require File.dirname(__FILE__) + '/../test_helper'

class ClubsControllerTest < ActionController::TestCase
  fixtures :customers, :clubs, :users, :roles, :roles_users

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:clubs)
  end

  def test_should_get_csv_index
    m = mock()
    @controller.expects(:report_table_from_objects).once.returns(m)
    m.expects(:as).with(:csv).returns('result')
    @request.env['HTTP_ACCEPT'] = 'text/csv'
    get :index
    assert_response :success
    assert_equal 'result', @response.body
    assert_equal 'text/csv', @response.content_type
  end

  def test_should_get_new
    login_as :admin
    get :new, :customer_id => 1
    assert_response :success
  end

  def test_should_create_club
    login_as :admin
    Club.delete_all :customer_id => 1
    assert_difference('Club.count') do
      post :create, :club => { :customer_id => 1, :name => 'Testing' }
    end

    assert_redirected_to customer_path(assigns(:club).customer_id)
  end

  def test_should_show_club
    get :show, :id => clubs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => clubs(:one).id
    assert_response :success
  end

  def test_should_update_club
    login_as :admin
    put :update, :id => clubs(:one).id, :club => { :customer_id => 1, :name => 'New Name' }
    assert_redirected_to customer_path(assigns(:club).customer_id)
  end

  def test_should_destroy_club
    login_as :admin
    assert_difference('Club.count', -1) do
      delete :destroy, :id => clubs(:one).id
    end

    assert_redirected_to customer_path(1)
  end
end
