require File.dirname(__FILE__) + '/../test_helper'

class CustomersControllerTest < ActionController::TestCase
  fixtures :customers, :customer_types, :delivery_methods, :regions, :customer_notes, :delivery_methods, :special_orders, :special_order_lines

  def test_application_default_url_options
    # Bug #60
    Customer.expects(:per_page).returns(1)
    get :index, { :q => '*', :page => 2 }
    # Assert we have links to "page 1" and "page 3"
    # We can't just use url_for, because that's what we're testing!
    assert_tag :tag => 'a', :attributes => { :href => /(\?page=1&amp;q=%2A|\?q=%2A&amp;page=1)$/ }
    assert_tag :tag => 'a', :attributes => { :href => /(\?page=3&amp;q=%2A|\?q=%2A&amp;page=3)$/ }
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_index_with_invalid_page
    get :index, :page => -1
    assert_response :success
  end

  def test_index_with_zero_page
    get :index, :page => 0
    assert_response :success
  end

  def test_index_with_huge_page
    get :index, :page => 999999
    assert_response :success
  end

  def test_show
    get :show, :id => 1
    assert_response :success
  end

  def test_show_with_note_with_invalid_user
    n = customers(:customer1).notes.first
    n.created_by = nil
    n.save!

    get :show, :id => 1
    assert_response :success
  end

  def test_show_with_special_order_line_with_invalid_user
    User.find(1).destroy

    get :show, :id => 1
    assert_response :success
  end
end
