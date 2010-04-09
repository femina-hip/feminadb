class Messenger
  @@sender_class = XMPP

  def initialize(sender = @@sender_class.new)
    @sender = sender
  end

  def send_message(recipients, body)
    return unless @sender and not recipients.empty?
    @sender.send_message recipients, body
  end
end
