require File.dirname(__FILE__) + '/../test_helper'

class CustomerStandingOrdersControllerTest < ActionController::TestCase
  fixtures :customers, :publications, :standing_orders, :users, :roles, :roles_users

  def test_new
    login_as :admin
    get :new, :customer_id => 1
    assert_response :success
  end

  def test_new_only_shows_publications_with_standing_orders
    t = Publication.create!(:name => 'T1', :tracks_standing_orders => true)
    f = Publication.create!(:name => 'T2', :tracks_standing_orders => false)
    login_as :admin
    get :new, :customer_id => 1
    assert_tag :option, :attributes => { :value => t.id.to_s }
    assert_no_tag :option, :attributes => { :value => f.id.to_s }
  end

  def test_edit
    login_as :admin
    get :edit, :customer_id => 1, :id => 1
    assert_response :success
  end
end
