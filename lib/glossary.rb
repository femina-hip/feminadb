module Glossary # To be included in ApplicationHelper
  # Returns HTML for a term (that is, a title) and a glossary tooltip
  def glossary_term_and_tooltip(term)
    render(:partial => 'application/glossary_term', :locals => { :term => term, :definition => Data[term] })
  end

  private
    Data = {
            'Order' => 'The desire to transfer a certain number of Copies of a particular Issue from a Warehouse to a Customer',
            'Orders' => 'The desires to transfer a certain number of Copies of some particular Issues from a Warehouse to a Customer',
            'Address' => 'Final destination: where the Customer actually is.',
            'Deliver Via' => 'Company to which Femina sends an Issue (which may not be the final Customer)',
            'Distribution List' => 'A list, sorted by Region and District, of each Customer, its Address, and how many Copies it should receive (based on its Order)',
            'Distribution Quote Request' => 'A communication with a distributor regarding a particular Issue. Femina describes how many Customers in each Region have Orders for that Issue, and how many Copies of the Issue will be distributed onto each Region. The Up-Country Distributor is expected to respond with a quote.',
            'Distribution Order' => 'A communication with a distributor regarding a particular Issue. Femina describes, for each Delivery Method, how many Customers in each Region have Orders for that Issue, and how many Copies of the Issue will be distributed onto each Region.',
            'Issue' => 'A print run of Fema, a print run of Si Mchezo!, or another one-off printing which must be Distributed',
            'Issue Number' => 'A number representing an Issue. For a magazine, this is the Issue Number. For other publications, this is some unique sequence of numbers, letters, dashes, and periods.',
            'Publication' => 'A magazine or type of product. For instance: Fema, Si Mchezo!, Pens, or Kangas.',
            'Route' => 'Order in which to deliver. This should be a name of a route and then a number: for instance, "city07".',
            'Standing Order' => 'The desire of a Customer to receive a certain number of Copies of each future Issue of a particular Publication. When a new Issue is released, a new Customer Order will be created for each Standing Order.',
            'Standing Orders' => 'The desires of Customers to receive Copies of each future Issue of particular Publications. When a new Issue is released, a new Customer Order will be created for each Standing Order.',
            'Waiting Order' => 'The desire of a Customer to have a Standing Order, which we (Femina) have denied for the time being.',
            'Waiting Orders' => 'The desires of Customers to have Standing Orders, which we (Femina) have denied for the time being.'
    }
    Data.freeze
end
