require File.dirname(__FILE__) + '/../test_helper'

class SToOMailerTest < ActionMailer::TestCase
  def test_send_log
    recipients = [ 'adamh@feminahip.or.tz' ]
    issue = Issue.find(1)
    log = { :errors => [], :skipped => [], :created => [], :updated => [] }

    response = SToOMailer.create_report(recipients, issue, log)

    assert true
  end
end
