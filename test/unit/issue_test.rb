require File.dirname(__FILE__) + '/../test_helper'

class IssueTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true
  fixtures(:issues, :issue_box_sizes, :publications, :orders, :delivery_methods, :regions)

  def test_new_with_box_sizes
    i = Issue.new(:publication_id => 3, :name => 'Testing Testing', :issue_date => Date.parse('3 December, 2007'), :issue_number => 1)
    ibs = i.issue_box_sizes.build(:num_copies => 1)
    assert ibs.valid?
    assert i.valid?
    i.save!
    i.issue_box_sizes.each { |ibs| ibs.save! }
    id = i.id
    assert_equal 1, Issue.find(id).issue_box_sizes.length
  end

  def test_issue_box_size_quantities_one_box_exactly
    # Test each exact size finds the exact right box
    [ @ibs11, @ibs12, @ibs13, @ibs14, @ibs15 ].each do |ibs|
      ret = @issue1.issue_box_size_quantities(ibs.num_copies)
      assert_equal({ ibs.num_copies => 1 }, ret, 'Should perfectly fit into one box')
    end
  end

  def test_issue_box_size_quantities_uses_one_box_when_possible
    ret = @issue1.issue_box_size_quantities(150)
    assert_equal({ 75 => 2 }, ret, 'Should use same box size when possible')
  end

  def test_issue_box_size_quantities_other_box_sizes_zeroed
    ret = @issue1.issue_box_size_quantities(100)
    [ @ibs11, @ibs12, @ibs13, @ibs14 ].each do |ibs|
      assert_equal 0, ret[ibs.num_copies]
    end
  end

  def test_issue_box_size_quantities_can_use_two_boxes
    ret = @issue1.issue_box_size_quantities(275)
    assert_equal({ 100 => 2, 75 => 1 }, ret,
        'Should use two different box sizes when necessary')
  end

  def test_issue_box_size_quantities_can_use_three_boxes
    ret = @issue1.issue_box_size_quantities(177)
    assert_equal({ 100 => 1, 75 => 1, 2 => 1 }, ret,
        'Should use three different box sizes when necessary')
  end

  def test_issue_box_size_quantities_does_not_mix_ones
    ret = @issue1.issue_box_size_quantities(51)
    assert_equal({ 1 => 51 }, ret,
        'Do not mix size of 1 with any other size')
  end

  def test_issue_box_sizes_string
    assert_equal '1, 2, 50, 75, 100', @issue1.issue_box_sizes_string
  end

  def test_issue_box_sizes_string_setter
    @issue1.issue_box_sizes_string = '1, 2, 3'
    assert_equal '1, 2, 3', @issue1.issue_box_sizes_string(true)
  end

  def test_issue_box_sizes_string_setter_remove_one
    @issue1.issue_box_sizes_string = '1, 50, 75, 100'
    assert_equal '1, 50, 75, 100', @issue1.issue_box_sizes_string(true)
  end

  def test_issue_box_sizes_string_setter_add_one
    @issue1.issue_box_sizes_string = '1, 2, 3, 50, 75, 100'
    [ @ibs11, @ibs12, @ibs13, @ibs14, @ibs15 ].each do |ibs|
      assert IssueBoxSize.exists?(ibs), 'Existing IBSs were not removed'
    end
    assert_equal 6, @issue1.issue_box_sizes.length
  end

  def test_issue_box_sizes_string_setter_remove_last
    @issue1.issue_box_sizes_string = '1, 2, 50, 75'
    [ @ibs11, @ibs12, @ibs13, @ibs14 ].each do |ibs|
      assert IssueBoxSize.exists?(ibs)
    end
    assert_equal 4, @issue1.issue_box_sizes.length
  end

  def test_issue_box_sizes_string_setter_add_last
    @issue1.issue_box_sizes_string = '1, 2, 50, 75, 100, 150'
    [ @ibs11, @ibs12, @ibs13, @ibs14, @ibs15 ].each do |ibs|
      assert IssueBoxSize.exists?(ibs), 'Existing IBSs were not removed'
    end
    assert_equal 6, @issue1.issue_box_sizes.length
  end

  def test_issue_box_sizes_string_setter_sorts_properly
    @issue1.issue_box_sizes_string = '1, 100, 50, 75, 2'
    [ @ibs11, @ibs12, @ibs13, @ibs14, @ibs15 ].each do |ibs|
      assert IssueBoxSize.exists?(ibs), 'Existing IBSs were not removed'
    end
    assert_equal '1, 2, 50, 75, 100', @issue1.issue_box_sizes_string
  end

  def test_issue_box_sizes_string_setter_uniqs_properly
    @issue1.issue_box_sizes_string = '1, 1, 1, 1, 1'
    assert IssueBoxSize.exists?(@ibs11)
    assert_equal 1, @issue1.issue_box_sizes.length
  end

  def test_issue_box_sizes_string_setter_validates_properly
    assert_equal true, @issue1.valid?
    @issue1.issue_box_sizes_string = "Hello"
    assert_equal false, @issue1.valid?
  end

  def test_issue_box_sizes_string_setter_sets_empty_properly
    @issue1.issue_box_sizes_string = ''
    assert @issue1.valid?
    assert_equal 0, @issue1.issue_box_sizes.length
  end

  def test_fail_issue_box_size_quantities
    assert_raises(Issue::DoesNotFitInBoxesException) { @issue2.issue_box_size_quantities(1) }
  end

  def test_distribution_list_does_not_crash_always
    @issue1.distribution_list_data
    assert true
  end

  def test_distribution_quote_request_does_not_crash_always
    @issue1.distribution_quote_request_data
    assert true
  end

  def test_distribution_list_does_not_hold_deleted_items
    i = issues(:issue_free)
    o = i.orders.create!(:num_copies => 20, :delivery_method_id => 1, :region_id => 1, :customer_id => 1)
    o.destroy

    dl = i.distribution_list_data
    assert dl.to_a.empty?
  end

  def test_distribution_quote_request_does_not_hold_deleted_items
    i = issues(:issue_free)
    o = i.orders.create!(:num_copies => 20, :delivery_method_id => 1, :region_id => 1, :customer_id => 1)
    o.destroy

    dqr = i.distribution_quote_request_data
    assert dqr.empty?
  end

  def test_distribution_quote_request_only_holds_quoted_items
    i = issues(:issue2)
    dqr = i.distribution_quote_request_data
    assert_equal [{ :num_copies => 100, :region_name => 'Region1', :num_recipients => 1}], dqr
  end

  def test_issue_number_format
    i = issues(:issue1)
   assert i.valid?
    [ 'A', 'Y', '123', '01', '23.3', '12a', '2-3' ].each do |num|
      i.issue_number = num
      assert i.valid?, "allows issue_number of #{num}"
    end
    i.issue_number = '2_2'
    assert !i.valid?, 'does not allow 2_2'
  end
end
