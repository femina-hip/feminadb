module CustomersHelper
  def telephones_string(customer)
    h [ customer.telephone_1, customer.telephone_2, customer.telephone_3 ].collect{|ct| ct.to_s.strip}.select{|ct| not ct.empty?}.join(', ')
  end

  def emails_string(customer)
    [ customer.email_1, customer.email_2 ].collect{|e| e.to_s.strip}.select{|e| not e.empty?}.collect{|e| mail_to(e)}.join(', ')
  end

  def website_string(customer)
    url = customer.website.to_s.strip
    return '' if url.empty?
    url = "http://#{url}" unless url =~ /^https?:/
    link_to url, url, :popup => true
  end
end
