require File.dirname(__FILE__) + '/../test_helper'

class CustomerWaitingOrdersControllerTest < ActionController::TestCase
  fixtures :customers, :waiting_orders, :users, :roles, :roles_users, :publications

  def test_new
    login_as :admin
    get :new, :customer_id => 1
    assert_response :success
  end

  def test_create
    login_as :admin
    old_count = WaitingOrder.count
    post :create, :customer_id => 1, :waiting_order => { :publication_id => 3, :num_copies => '10', :request_date => '2008-02-01' }
    assert_equal old_count + 1, WaitingOrder.count
    assert_redirected_to customer_path(1)
  end

  def test_new_shows_all_publications
    login_as :admin
    t = Publication.create!(:name => 'T1', :tracks_standing_orders => true)
    f = Publication.create!(:name => 'T2', :tracks_standing_orders => false)
    get :new, :customer_id => 1
    assert_tag :option, :attributes => { :value => t.id }
    assert_tag :option, :attributes => { :value => f.id }
  end
end
