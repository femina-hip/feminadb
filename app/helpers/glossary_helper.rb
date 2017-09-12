module GlossaryHelper
  def glossary_term(term)
    content_tag(:abbr, term, :title => glossary_helper_definition(term))
  end

  private

  def glossary_helper_definition(term)
    case term
    when 'Expired SMS numbers' then 'Any SMS numbers that we removed from the customer, but which still exists in Telerivet'
    when 'Headmaster SMS numbers' then 'SMS numbers for school headmasters (and ONLY school headmasters), whom we can contact with Telerivet'
    when 'Primary Contact SMS numbers' then 'SMS numbers for the person who receives magazines from us, whom we can contact with Telerivet'
    when 'Club Mentor SMS numbers' then 'SMS numbers for Club Mentors, etc. (ONLY if a club exists), whom we can contact with Telerivet. If there is an SMS number here, that means the school has a club.'
    when 'Student SMS numbers' then 'SMS numbers for students, current or former, whom we can contact with Telerivet'
    when 'Order' then 'The desire to transfer a certain number of Copies of a particular Issue from a Warehouse to a Customer'
    when 'Orders' then 'The desires to transfer a certain number of Copies of some particular Issues from a Warehouse to a Customer'
    when 'Delivery address' then 'How the person delivering Copies gets them to the recipient. If there is an intermediary, include all information: for instance, "via office A in village B, to school C in village D"'
    when 'Delivery contact' then 'Name, position and/or phone number of somebody to contact when trying to deliver Copies to the Customer'
    when 'Distribution List' then 'A list, sorted by Region and Council, of each Customer, its Address, and how many Copies it should receive (based on its Order)'
    when 'Distribution Order' then 'A communication with a distributor regarding a particular Issue. Femina describes, for each Delivery Method, how many Customers in each Region have Orders for that Issue, and how many Copies of the Issue will be distributed onto each Region.'
    when 'Issue' then 'A print run of Fema, a print run of Si Mchezo!, or another one-off printing which must be Distributed'
    when 'Issue Number' then 'A number representing an Issue. For a magazine, this is the Issue Number. For other publications, this is some unique sequence of numbers, letters, dashes, and periods.'
    when 'Publication' then 'A magazine or type of product. For instance: Fema, Si Mchezo!, Pens, or Kangas.'
    when 'Standing Order' then 'The desire of a Customer to receive a certain number of Copies of each future Issue of a particular Publication. When a new Issue is released, a new Customer Order will be created for each Standing Order.'
    when 'Standing Orders' then 'The desires of Customers to receive Copies of each future Issue of particular Publications. When a new Issue is released, a new Customer Order will be created for each Standing Order.'
    else '(Sorry, there is no definition here)'
    end
  end
end
