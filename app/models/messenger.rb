class Messenger
  @@sender_class = XMPP
  cattr_accessor :sender_class

  def initialize(sender = @@sender_class.new)
    @sender = sender
  end

  def send_special_order_created(special_order_id)
    special_order = SpecialOrder.find(special_order_id)
    recipients = get_recipients('special_order_created')
    body = "A new Special Order was created. Browse to http://db/special_orders/#{special_order.id} and log in to approve it."
    do_send(recipients, body)
  end

  def send_special_order_approved(special_order_id)
    special_order = SpecialOrder.find(special_order_id)
    recipients = get_recipients('special_order_approved') + get_stakeholder_emails(special_order)
    body = "Special Order ##{special_order.id} was approved. Browse to http://db/special_orders/#{special_order.id} to see it."
    do_send(recipients, body)
  end

  def send_special_order_denied(special_order_id)
    special_order = SpecialOrder.find(special_order_id)
    recipients = get_recipients('special_order_denied') + get_stakeholder_emails(special_order)
    body = "Special Order ##{special_order.id} was denied. Browse to http://db/special_orders/#{special_order.id} to see it."
    do_send(recipients, body)
  end

  private
    def get_recipients(type)
      CONFIG.read('messenger', "#{type}_recipients").to_a.compact.uniq
    end

    def get_stakeholder_emails(special_order)
      [ special_order.requested_by_user, special_order.authorized_by_user ].compact.collect{|u| u.email}
    end

    def do_send(recipients, body)
      return unless @sender and not recipients.empty?
      @sender.send_message recipients, body
    end
end
