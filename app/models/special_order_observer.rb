class SpecialOrderObserver < ActiveRecord::Observer
  def after_create(special_order)
    do_send :special_order_created, special_order
  end

  def after_save(special_order)
    # Not after_update because we MUST be called after acts_as_versioned
    state = special_order.state
    prev = special_order.versions.before(special_order.versions.latest)
    prev_approved = !prev.nil? && (prev.authorized_by.to_i != 0) && prev.approved
    prev_denied = !prev.nil? && (prev.authorized_by.to_i != 0) && !prev_approved

    if !prev_approved and state == :approved
      do_send :special_order_approved, special_order
    elsif !prev_denied and state == :denied
      do_send :special_order_denied, special_order
    end
  end

  #private # Not private because it breaks Mocha's unit testing
    def do_send(message_type, special_order)
      ::MiddleMan.new_worker(
        :class => :background_messenger_worker,
        :args => [ "send_#{message_type.to_s}".to_sym, special_order.id ]
      )
    end
end
