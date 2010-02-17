require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../mocks/test/backgroundrb_mock'
Messenger.sender_class = nil

class SpecialOrdersControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = false

  fixtures :special_orders, :special_order_lines, :users, :roles, :roles_users, :issues, :publications, :customers, :special_order_versions, :special_order_line_versions, :issue_versions, :publication_versions, :special_order_versions

  def test_index
    get :index
    assert_response :success
    assert assigns(:pending_special_orders)
    assert assigns(:approved_special_orders)
    assert assigns(:special_orders)
  end

  def test_index_with_invalid_user
    User.find(1).destroy
    get :index
    assert_response :success
  end

  def test_show
    get :show, :id => 1
    assert_response :success
    assert assigns(:special_order)
    assert_template 'show_pending'
  end

  def test_show_with_invalid_user
    User.find(1).destroy
    get :show, :id => 1
    assert_response :success
  end

  def test_show_approved
    login_as :admin
    put :approve, :id => 1, :special_order => { }, :lines => { '1' => { :num_copies => 1 } }
    assert_response :redirect

    get :show, :id => 1
    assert_response :success
    assert assigns(:special_order)
    assert_template 'show_approved'
  end

  def test_show_approved_with_invalid_user
    put :approve, :id => 1, :special_order => { }, :lines => { '1' => { :num_copies => 1 } }
    assert_response :redirect

    users(:admin).destroy

    get :show, :id => 1
    assert_response :success
  end

  def test_show_completed
    login_as :admin
    put :approve, :id => 1, :special_order => { }, :lines => { '1' => { :num_copies => 1 } }
    assert_response :redirect
    put :complete, :id => 1
    assert_response :redirect

    get :show, :id => 1
    assert_response :success
    assert assigns(:special_order)
    assert_template 'show_completed'
  end

  def test_show_completed_with_invalid_user
    put :approve, :id => 1, :special_order => { }, :lines => { '1' => { :num_copies => 1 } }
    assert_response :redirect
    put :complete, :id => 1
    assert_response :redirect

    users(:admin).destroy

    get :show, :id => 1
    assert_response :success
  end

  def test_show_denied
    login_as :admin
    put :deny, :id => 1, :special_order => { }
    assert_response :redirect

    get :show, :id => 1
    assert_response :success
    assert assigns(:special_order)
    assert_template 'show_denied'
  end

  def test_show_denied_with_invalid_user
    login_as :admin
    put :deny, :id => 1, :special_order => { }
    assert_response :redirect

    users(:admin).destroy

    get :show, :id => 1
    assert_response :success
  end

  def test_new
    login_as :admin
    get :new
    assert_response :success
    assert_nil assigns(:special_order).customer
    assert_tag :tag => 'input', :attributes => { :name => 'special_order[customer_name]' }
    assert_no_tag :tag => 'input', :attributes => { :name => 'special_order[customer_id]' }
  end

  def test_new_with_customer
    login_as :admin
    get :new, :customer_id => 1
    assert_response :success
    assert assigns(:special_order).customer
    assert_tag :tag => 'input', :attributes => { :name => 'special_order[customer_id]', :value => 1 }
    assert_no_tag :tag => 'input', :attributes => { :name => 'special_order[customer_name]' }
  end

  def test_create
    login_as :admin
    expected_date = DateTime.parse('Tue Dec 04 15:38:00 +0300 2007')
    DateTime.stubs(:now).returns expected_date

    old_count = SpecialOrder.count
    post :create, :special_order => { :customer_name => 'Testing', :reason => 'Beacuse', :requested_for_date => Date.parse('2007-12-04') }, :lines => { 0 => { :num_copies_requested => 10, :issue_id => 1 } }
    assert_equal old_count+1, SpecialOrder.count

    assert id = assigns(:special_order)
    assert_redirected_to :controller => 'special_orders', :action => 'show'
    assert_equal expected_date, SpecialOrder.find(id).requested_at.to_datetime
    assert_equal 3, SpecialOrder.find(id).requested_by
    assert_nil SpecialOrder.find(id).customer
  end

  def test_create_with_customer
    login_as :admin
    old_count = SpecialOrder.count
    post :create, :special_order => { :customer_id => 1, :reason => 'Beacuse', :requested_for_date => Date.parse('2007-12-04') }, :lines => { 0 => { :num_copies_requested => 10, :issue_id => 1 } }
    assert_equal old_count+1, SpecialOrder.count

    assert id = assigns(:special_order)
    assert_equal 3, SpecialOrder.find(id).requested_by
    assert_equal 1, SpecialOrder.find(id).customer_id
    assert_equal 'MyString', SpecialOrder.find(id).customer_name
  end

  def test_approve
    login_as :admin
    expected_date = DateTime.parse('2007-12-04 15:48:00 +0300 2007')
    DateTime.stubs(:now).returns expected_date

    put :approve, :id => 1, :special_order => { }, :lines => { '1' => { :num_copies => 1 } }
    assert_redirected_to :controller => 'special_orders', :action => 'index'
    so = SpecialOrder.find(1)
    assert so.approved?
    assert_equal expected_date, so.authorized_at.to_datetime
    assert_equal 3, so.authorized_by
  end

  def test_approve_subtracts_in_house
    login_as :admin
    assert_equal 1, issues(:issue1).num_copies_in_house
    put :approve, :id => 1, :special_order => { }, :lines => { '1' => { :num_copies => 1 } }
    issues(:issue1).reload
    assert_equal 0, issues(:issue1).num_copies_in_house
  end

  def test_approve_failure_rolls_back
    login_as :admin
    SpecialOrderLine.any_instance.stubs(:save!).raises(ActiveRecord::RecordNotSaved)
    put :approve, :id => 1, :special_order => { }, :lines => { '1' => { :num_copies => 1 } }
    assert_response :success
    assert_equal 1, issues(:issue1).num_copies_in_house
    special_orders(:one).reload
    assert_nil special_orders(:one).authorized_by
  end

  def test_deny
    login_as :admin
    expected_date = DateTime.parse('2007-12-04 15:48:00 +0300 2007')
    DateTime.stubs(:now).returns expected_date

    put :deny, :id => 1, :special_order => { }
    assert_redirected_to :controller => 'special_orders', :action => 'index'
    so = SpecialOrder.find(1)
    assert so.denied?
    assert_equal expected_date, so.authorized_at.to_datetime
    assert_equal 3, so.authorized_by
  end
end
