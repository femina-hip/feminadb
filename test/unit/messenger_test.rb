require File.dirname(__FILE__) + '/../test_helper'

class MessengerTest < Test::Unit::TestCase
  fixtures :special_orders, :users

  class MockSender
    attr_reader :recipients, :body
    def send_message(recipients, body)
      @recipients = recipients
      @body = body
    end
  end

  def test_send_special_order_created
    sender = MockSender.new
    Messenger.new(sender).send_special_order_created(special_orders(:one).id)
    assert sender.recipients.is_a?(Array)
    assert sender.body =~ %r(http://db/special_orders/1)
  end

  def test_send_special_order_created_recipients
    sender = MockSender.new
    Messenger.new(sender).send_special_order_created(special_orders(:one).id)
    assert sender.recipients.is_a?(Array)
    assert_equal [ 'test@localhost', 'test2@localhost' ], sender.recipients
  end

  def test_send_special_order_updated_recipients
    sender = MockSender.new
    Messenger.new(sender).send_special_order_approved(special_orders(:one).id)
    assert_equal [ 'test@localhost', 'quentin@example.com' ], sender.recipients
  end

  def test_send_special_order_denied_recipients
    sender = MockSender.new
    Messenger.new(sender).send_special_order_denied(special_orders(:one).id)
    assert_equal [ 'test2@localhost', 'quentin@example.com' ], sender.recipients
  end
end
