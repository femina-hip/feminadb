require "#{File.dirname(__FILE__)}/../test_helper"

class CustomerSearchSavingTest < ActionController::IntegrationTest
  fixtures :customers, :regions, :customer_types

  def test_saves_search
    get '/customers'
    assert_equal 200, status
    n = assigns(:customers).total_entries
    assert_not_equal 0, n

    get '/customers?q=XXX_EXISTS_NOWHERE'
    assert_equal 200, status
    assert_equal 0, assigns(:customers).total_entries

    get '/customers'
    assert_equal 200, status
    assert_equal 0, assigns(:customers).total_entries
  end

  def test_clears_search
    get '/customers?q=XXX_EXISTS_NOWHERE'
    assert_equal 200, status
    assert_equal 0, assigns(:customers).total_entries

    get '/customers?q='
    assert_equal 200, status
    assert_not_equal 0, assigns(:customers).total_entries
  end
end
