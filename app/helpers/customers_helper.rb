module CustomersHelper
  def telephones_string(customer)
    [ customer.telephone_1, customer.telephone_2, customer.telephone_3 ].collect{|ct| ct.to_s.strip}.select{|ct| not ct.empty?}.join(', ')
  end

  def emails_string(customer)
    [ customer.email_1, customer.email_2 ].collect{|e| e.to_s.strip}.reject(&:empty?).collect{|e| mail_to(e)}.join(', ').html_safe
  end

  def website_string(customer)
    url = customer.website.to_s.strip
    return '' if url.empty?
    url = "http://#{url}" unless url =~ /^https?:/
    link_to(url)
  end

  def link_to_customer_club(s, customer)
    link_to(s, customer.club, :title => customer.club.name)
  end

  def standing_or_waiting_order_comments(standing_order, waiting_order)
    [ standing_order.try(:comments), waiting_order.try(:comments_with_request_date) ].compact.join(' | ')
  end

  def standing_or_waiting_order_string(standing_order, waiting_order)
    s = standing_order.try(:num_copies).blank? ? nil : standing_order.num_copies
    w = waiting_order.try(:num_copies).blank? ? nil : waiting_order.num_copies

    if !s && !w
      "&nbsp;".html_safe
    else
      [ s, w && "#{w}W" ].compact.join(' + ')
    end
  end
end
