require File.dirname(__FILE__) + '/../test_helper'

class RegionTest < Test::Unit::TestCase
  fixtures :regions

  def test_create
    assert_nothing_raised do
      Region.create! :name => 'test_create Region', :population => 50
    end
  end

  def test_create_empty_name_not_allowed
    assert_raise ActiveRecord::RecordInvalid do
      Region.create!(:population => 10)
    end
  end
end
