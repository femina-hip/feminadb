require File.dirname(__FILE__) + '/../test_helper'

class IssuesControllerTest < ActionController::TestCase
  fixtures :publications, :issues, :regions, :customers, :orders, :delivery_methods, :users, :roles, :roles_users, :issue_box_sizes, :special_orders, :special_order_lines

  def test_show_packing_instructions
    get :show_packing_instructions, { :id => 1, :publication_id => 1 }
    assert_response :success
  end

  def test_show_packing_instructions_with_bad_sizes
    Order.create! :issue_id => 2, :customer_id => 1, :num_copies => 1
    get :show_packing_instructions, { :id => 2, :publication_id => 2 }
    assert_response :success
  end

  def test_show_distribution_list
    get :show_distribution_list, { :id => 1, :publication_id => 1 }
    assert_response :success
  end

  def test_show_distribution_list_with_bad_sizes
    Order.create! :issue_id => 2, :customer_id => 1, :num_copies => 1
    get :show_distribution_list, { :id => 2, :publication_id => 2 }
    assert_response :success
  end

  def test_show_distribution_quote_request
    get :show_distribution_quote_request, { :id => 1, :publication_id => 1 }
    assert_response :success
  end

  def test_show_distribution_order
    get :show_distribution_quote_request, { :id => 1, :publication_id => 1 }
    assert_response :success
  end

  def test_show_distribution_list_with_nil_fields
    Order.connection.execute('INSERT INTO orders (id, customer_id, issue_id, num_copies, region_id, delivery_method_id) VALUES (99999, 3, 1, 50, NULL, NULL)')
    get :show_distribution_list, { :id => 1, :publication_id => 1 }
    assert_response :success
  end

  def test_show_special_order_lines_with_invalid_user
    User.find(1).destroy
    get :show_special_order_lines, { :id => 1, :publication_id => 1 }
    assert_response :success
  end

  def test_show_special_order_lines
    get :show_special_order_lines, { :id => 1, :publication_id => 1 }
    assert_response :success
    assert_select 'a[href=?]', special_order_url(:id => 1, :only_path => true)
  end

  def test_show_special_order_lines_with_empty
    SpecialOrderLine.delete_all :issue_id => 1
    get :show_special_order_lines, { :id => 1, :publication_id => 1 }
    assert_response :success
  end
end
