require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :tags

  def test_validate_normalized
    tag = Tag.new(:name => 'hello', :num_customers => 1)
    assert !tag.valid?
    tag.name = 'HELLO'
    assert_valid tag
  end

  def test_normalize_name!
    tag = Tag.new(:name => 'hello', :num_customers => 1)
    tag.normalize_name!
    assert_equal 'HELLO', tag.name
  end

  def test_validate_positive_num_customers
    tag = Tag.new(:name => 'HELLO', :num_customers => 0)
    assert !tag.valid?
    tag.num_customers = -4
    assert !tag.valid?
    tag.num_customers = 1
    assert_valid tag
  end
end
