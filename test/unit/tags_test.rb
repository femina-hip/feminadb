require File.dirname(__FILE__) + '/../test_helper'

class TagsTest < ActiveSupport::TestCase
  def test_normalize_uppercases
    assert_equal 'HELLO', Tags.normalize_name('hello')
  end

  def test_normalize_adds_underscores
    assert_equal 'HEL_LO', Tags.normalize_name('HEL LO')
  end

  def test_normalize_never_puts_two_underscores
    assert_equal 'HEL_LO', Tags.normalize_name('HEL  LO')
    assert_equal 'HEL_LO', Tags.normalize_name('HEL _LO')
    assert_equal 'HEL_LO', Tags.normalize_name('HEL__LO')
  end

  def test_normalize_allows_numbers
    assert_equal 'HELLO1', Tags.normalize_name('hello1')
  end

  def test_normalize_removes_tag_prefix
    assert_equal 'HELLO', Tags.normalize_name('TAG_HELLO')
    assert_equal 'HELLO', Tags.normalize_name('TAG HELLO')
    assert_equal 'HELLO', Tags.normalize_name('tag+HELLO')
    assert_equal 'HELLO', Tags.normalize_name('tag hello')
    assert_equal '_TAG_HELLO', Tags.normalize_name('_TAG_HELLO')
    assert_equal 'TAGHELLO', Tags.normalize_name('TAGHELLO')
  end
end
