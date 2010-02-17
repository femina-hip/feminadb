require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../mocks/test/backgroundrb_mock'

class SToOWorkerTest < Test::Unit::TestCase
  def test_mails_error
    SToOMailer.expects(:deliver_exception).once
    Issue.stubs(:find).raises
    ::MiddleMan.new_worker(:class => :s_to_o_worker, :args => { :issue_id => 1, :recipients => [ 'adamh@feminahip.or.tz' ] })
  end
end
