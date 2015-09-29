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
end
