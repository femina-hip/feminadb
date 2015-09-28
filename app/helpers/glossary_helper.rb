module GlossaryHelper
  def glossary_term(term)
    content_tag(:abbr, term, :title => glossary_helper_definition(term))
  end

  private

  def glossary_helper_definition(term)
    case term
    when 'SMS numbers' then 'SMS numbers for headmasters, etc., whose information we store in Telerivet'
    when 'Old SMS numbers' then 'SMS numbers for headmasters, etc., which we have stored in Telerivet; but we think the number no longer works or the contact is no longer at the school'
    when 'Club SMS numbers' then 'SMS numbers for Club Guardians, etc., which we can use with Telerivet'
    when 'Old Club SMS numbers' then 'SMS numbers for Club Guardians, etc., which we once used with Telerivet; but we think the number no longer works or the contact is no longer a Club Guardian'
    when 'Student SMS numbers' then 'SMS numbers for students, current or former, who have contacted Femina through Telerivet'
    when 'Order' then 'The desire to transfer a certain number of Copies of a particular Issue from a Warehouse to a Customer'
    when 'Orders' then 'The desires to transfer a certain number of Copies of some particular Issues from a Warehouse to a Customer'
    when 'Delivery address' then 'How the person delivering Copies gets them to the recipient. If there is an intermediary, include all information: for instance, "via office A in village B, to school C in village D"'
    when 'Distribution List' then 'A list, sorted by Region and District, of each Customer, its Address, and how many Copies it should receive (based on its Order)'
    when 'Distribution Order' then 'A communication with a distributor regarding a particular Issue. Femina describes, for each Delivery Method, how many Customers in each Region have Orders for that Issue, and how many Copies of the Issue will be distributed onto each Region.'
    when 'Issue' then 'A print run of Fema, a print run of Si Mchezo!, or another one-off printing which must be Distributed'
    when 'Issue Number' then 'A number representing an Issue. For a magazine, this is the Issue Number. For other publications, this is some unique sequence of numbers, letters, dashes, and periods.'
    when 'Publication' then 'A magazine or type of product. For instance: Fema, Si Mchezo!, Pens, or Kangas.'
    when 'Standing Order' then 'The desire of a Customer to receive a certain number of Copies of each future Issue of a particular Publication. When a new Issue is released, a new Customer Order will be created for each Standing Order.'
    when 'Standing Orders' then 'The desires of Customers to receive Copies of each future Issue of particular Publications. When a new Issue is released, a new Customer Order will be created for each Standing Order.'
    when 'Waiting Order' then 'The desire of a Customer to have a Standing Order, which we (Femina) have denied for the time being.'
    when 'Waiting Orders' then 'The desires of Customers to have Standing Orders, which we (Femina) have denied for the time being.'
    else '(Sorry, there is no definition here)'
    end
  end
end
