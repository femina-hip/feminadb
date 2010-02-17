require File.dirname(__FILE__) + '/../test_helper'

class DistrictTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = true
  fixtures :districts

  def test_color_validation
    bad_district = District.new(:region_id => 2, :name => 'District3', :color => '#f32fac')
    assert_raises(ActiveRecord::RecordInvalid) { bad_district.save! }

    @d1.color = 'FEABCD'
    assert_equal('feabcd', @d1.color)

    @d1.color = '#012345'
    assert_equal('012345', @d1.color)

    @d1.color = 'Hello!'
    assert_equal('Hello!', @d1.color)
    assert_raises(ActiveRecord::RecordInvalid) { @d1.save! }
  end
end
