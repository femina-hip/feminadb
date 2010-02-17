require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../mocks/test/backgroundrb_mock'

class TestSender
  def initialize
    @@instance = self
  end
  cattr_reader :instance

  attr_reader :recipients, :body
  def send_message(recipients, body)
    @recipients = recipients
    @body = body
  end
end

class BackgroundMessengerWorkerTest < Test::Unit::TestCase
  fixtures :special_orders

  def setup
    @old_sender_class = Messenger.sender_class
    Messenger.sender_class = TestSender
  end

  def teardown
    Messenger.sender_class = @old_sender_class
  end

  def test_sends_message
    ::MiddleMan.new_worker(:class => :background_messenger_worker, :args => [ :send_special_order_created, special_orders(:one).id ])
    assert TestSender.instance
    assert TestSender.instance.recipients.is_a?(Array)
    assert TestSender.instance.body =~ %r(http://db/special_orders/1)
  end
end
