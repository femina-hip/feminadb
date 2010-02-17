require "#{File.dirname(__FILE__)}/../test_helper"
require File.dirname(__FILE__) + '/../mocks/test/backgroundrb_mock'

require 'messenger'
Messenger.sender_class = nil

class SpecialOrdersTest < ActionController::IntegrationTest
  fixtures :customers, :publications, :issues, :special_orders, :special_order_lines, :users, :roles, :roles_users, :regions

  def test_prompts_for_login
    get '/special_orders/new'
    assert_redirected_to '/account/login'

    post '/account/login', { :login => 'quentin', :password => 'test' }
    assert_redirected_to '/special_orders/new'

    follow_redirect!
    assert_response :success
    assert_tag :td, :content => 'quentin'
  end

  def test_create_special_order
    post '/account/login', { :login => 'quentin', :password => 'test' }
    assert_response :redirect

    post '/special_orders', {
      'special_order[customer_name]' => 'customer_name',
      'special_order[reason]' => 'reason',
      'special_order[requested_for_date]' => 'January 04, 2008',
      'lines[0][num_copies_requested]' => '10',
      'lines[0][issue_id]' => '1',
      'commit' => 'File Request'
    }
    assert_response :redirect

    follow_redirect!
    assert_response :success
    assert assigns(:special_order)
    assert_equal 1, assigns(:special_order).lines.length
  end

  def test_approve_special_order
    post '/account/login', { :login => 'admin', :password => 'test' }
    assert_response :redirect

    put '/special_orders/1/approve', {
      'lines[1][num_copies]' => '1',
      'lines[2][num_copies]' => '1',
      'special_order[authorize_comments]' => 'authorize_comments'
    }
    assert_response :redirect

    follow_redirect!
    assert_response :success

    assert special_orders(:one).approved?
    assert !special_orders(:one).completed?
  end

  def test_deny_special_order
    post '/account/login', { :login => 'admin', :password => 'test' }
    assert_response :redirect

    put '/special_orders/1/deny', {
      'special_order[authorize_comments]' => 'authorize_comments'
    }
    assert_response :redirect

    follow_redirect!
    assert_response :success

    assert special_orders(:one).denied?
    assert !special_orders(:one).completed?
  end

  def test_complete_special_order
    User.current_user = users(:admin)
    special_orders(:one).lines.first.num_copies = 1
    special_orders(:one).approve
    special_orders(:one).lines.first.save!
    special_orders(:one).save!

    post '/account/login', { :login => 'admin', :password => 'test' }
    assert_response :redirect

    put '/special_orders/1/complete', {}
    assert_response :redirect

    follow_redirect!
    assert_response :success

    special_orders(:one).reload
    assert special_orders(:one).completed?
  end
end
