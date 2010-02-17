require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../mocks/test/backgroundrb_mock'
require File.dirname(__FILE__) + '/../../lib/workers/bulk_order_worker'

class BulkOrderWorkerTest < Test::Unit::TestCase
  fixtures :customers, :standing_orders, :orders, :clubs, :delivery_methods, :regions, :customer_types, :issues, :publications # because of Search

  def test_with_publication
    args = {
        :issue_id => 4,
        :from_publication_id => 1,
        :q => 'blah',
        :num_copies => 10
    }

    BulkOrderCreator.expects(:do_copy_from_publication).with(args)
    ::MiddleMan.new_worker(:class => :bulk_order_worker, :args => args)
  end

  def test_with_issue
    args = {
      :issue_id => 4,
      :from_issue_id => 1,
      :q => 'blah',
      :delivery_method_id => 2
    }

    BulkOrderCreator.expects(:do_copy_from_issue).with(args)
    ::MiddleMan.new_worker(:class => :bulk_order_worker, :args => args)
  end

  def test_with_customers
    args = {
      :issue_id => 4,
      :q => 'blah',
      :num_copies => 10
    }

    BulkOrderCreator.expects(:do_copy_from_customers).with(args)
    ::MiddleMan.new_worker(:class => :bulk_order_worker, :args => args)
  end
end
