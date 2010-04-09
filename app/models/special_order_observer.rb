class SpecialOrderObserver < ActiveRecord::Observer
  def after_create(special_order)
    send_special_order_created(special_order)
  end

  def after_save(special_order)
    # Not after_update because we MUST be called after acts_as_versioned
    state = special_order.state
    version_number = special_order.version
    changes = special_order.changes_between(version_number - 1, version_number)

    if changes['authorized_at'] && changes['authorized_at'].last
      if changes['approved'] && changes['approved'].last
        send_special_order_approved(special_order)
      else
        send_special_order_denied(special_order)
      end
    end
  end

  private

  def send_special_order_created(special_order)
    body = "A new Special Order was created. Browse to http://db/special_orders/#{special_order.id} and log in to approve it."
    send_message(:special_order_created, special_order, body)
  end

  def send_special_order_approved(special_order)
    body = "Special Order ##{special_order.id} was approved. Browse to http://db/special_orders/#{special_order.id} to see it."
    send_message(:special_order_approved, special_order, body)
  end

  def send_special_order_denied(special_order)
    body = "Special Order ##{special_order.id} was denied. Browse to http://db/special_orders/#{special_order.id} to see it."
    send_message(:special_order_denied, special_order, body)
  end

  def send_message(type, special_order, body)
    recipients = (get_recipients(type) + get_stakeholder_emails(special_order)).uniq
    Messenger.new.send_later(:send_message, recipients, body)
  end

  def get_recipients(type)
    CONFIG.read('messenger', "#{type}_recipients").to_a.compact.uniq
  end

  def get_stakeholder_emails(special_order)
    [ special_order.requested_by_user, special_order.authorized_by_user ].compact.collect{|u| u.email}
  end
end
