require File.dirname(__FILE__) + '/../test_helper'

class PublicationDistrictBreakdownControllerTest < ActionController::TestCase
  fixtures :publications, :regions, :orders, :issues

  def test_index
    get :index
    assert_response :success
    assert_select 'a[href=?]', @controller.url_for(:controller => 'issue_district_breakdown', :publication_id => 1, :only_path => true)
  end
end
