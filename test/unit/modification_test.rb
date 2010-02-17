require File.dirname(__FILE__) + '/../test_helper'

class ModificationTest < Test::Unit::TestCase
  # We'll test mostly with CustomerType, which is very simple
  fixtures :customer_types

  def test_added
    Time.stubs(:now).returns Time.parse('2007-12-06T11:46:41+03:00')

    ct = CustomerType.new(:name => 'M', :description => 'ModificationTest', :category => 'Testing')
    ct.save!

    mods = Modification.find_modifications(CustomerType, Time.now - 1.days)
    assert_equal 1, mods.length
    assert_equal ct.id, mods[0].o_id
    assert_equal :added, mods[0].type
  end

  def test_deleted
    Time.stubs(:now).returns Time.parse('2007-12-06T14:05:03+03:00')

    ct = CustomerType.new(:name => 'M', :description => 'ModificationTest', :category => 'Testing')
    ct.save!

    Time.stubs(:now).returns Time.parse('2007-12-08T14:05:03+03:00')
    ct.destroy

    mods = Modification.find_modifications(CustomerType, Time.now - 1.days)
    assert_equal 1, mods.length
    assert_equal ct.id, mods[0].o_id
    assert_equal :deleted, mods[0].type
  end

  def test_modified
    Time.stubs(:now).returns Time.parse('2007-12-06T14:05:03+03:00')

    ct = CustomerType.new(:name => 'M', :description => 'ModificationTest', :category => 'Testing')
    ct.save!

    Time.stubs(:now).returns Time.parse('2007-12-08T14:05:03+03:00')
    ct.update_attributes :description => 'ModificationTestAgain'

    mods = Modification.find_modifications(CustomerType, Time.now - 1.days)
    assert_equal 1, mods.length
    assert_equal ct.id, mods[0].o_id
    assert_equal :modified, mods[0].type
  end

  def test_created_and_destroyed
    Time.stubs(:now).returns Time.parse('2007-12-07T12:48:03+03:00')

    ct = CustomerType.new(:name => 'M', :description => 'ModificationTest', :category => 'Testing')
    ct.save!

    #File.open('/home/adam/t.txt', 'a') { |f| f.write("#{CustomerType.find(ct.id).inspect}\n") }
    Time.stubs(:now).returns Time.parse('2007-12-07T12:49:03+03:00') # +1min
    ct.destroy

    mods = Modification.find_modifications(CustomerType, Time.now - 1.days)
    assert_equal 1, mods.length
    assert_equal ct.id, mods[0].o_id
    assert_equal :modified, mods[0].type
    assert_nil mods[0].old_o
    assert_not_nil mods[0].new_o
  end
end
