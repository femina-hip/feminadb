require File.dirname(__FILE__) + '/../test_helper'

class PublicationTest < Test::Unit::TestCase
  fixtures :publications, :issues, :users, :roles, :roles_users

  def test_tracks_special_orders_scope
    assert_equal [ publications(:p1), publications(:p2) ], Publication.find_all_tracking_standing_orders(:order => :id)
  end

  def test_protects_issues
    assert_raise(ActiveRecord::ReferentialIntegrityProtectionError) do
      publications(:p1).destroy
    end
    Issue.delete_all
    assert_nothing_raised do
      publications(:p1).destroy
    end
  end
end
