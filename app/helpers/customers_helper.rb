module CustomersHelper
  # Shows customer[attribute] as an editable list, if allowed
  def show_sms_numbers(customer, attribute)
    options = { customer: customer, attribute: attribute }
    if current_user.has_role?('edit-customers')
      render('editable_sms_numbers', options)
    else
      render('static_sms_numbers', options)
    end
  end

  def sms_number_url(customer, sms_number)
    contact_id = customer.telerivet_id_cache[sms_number]
    if contact_id.present?
      TelerivetBridge.url_for_contact_id(contact_id)
    else
      nil
    end
  end

  def link_to_sms_number(customer, sms_number)
    url = sms_number_url(customer, sms_number)
    if url.present?
      content_tag(:a, sms_number, class: 'sms-number', href: url, target: '_blank')
    else
      content_tag(:span, sms_number, class: 'sms-number')
    end
  end
end
