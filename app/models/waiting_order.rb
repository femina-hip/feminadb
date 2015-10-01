# encoding: utf-8
class WaitingOrder < ActiveRecord::Base
  belongs_to(:customer)
  belongs_to(:publication)

  after_save { |wo| wo.customer.try(:index) }

  validates_presence_of :customer_id
  validates_presence_of :publication_id
  validates_presence_of :request_date
  validates_uniqueness_of :publication_id, scope: :customer_id
  validates(:num_copies, numericality: { only_integer: true, greater_than: 0 })

  def customer_delivery_method
    customer.delivery_method
  end

  def customer_region
    customer.region
  end

  def customer_type
    customer.type
  end

  def comments_with_request_date
    if request_date
      "(requested #{request_date.to_formatted_s(:long)}) #{comments}"
    elsif comments
      comments
    else
      nil
    end
  end

  def standing_order_create_params
    ret = attributes.slice(:customer_id, :publication_id, :num_copies)
    ret[:comments] = "From Waiting Order #{request_date.to_formatted_s(:long)}: #{comments}"
    ret
  end

  def title
    "#{num_copies} #{publication.name} → #{customer.name}"
  end

  def self.customer_ids_with_publication_id(publication_id)
    Customer.connection.execute("""
      SELECT customer_id
      FROM waiting_orders
      WHERE publication_id = #{publication_id.to_i}
    """).map { |row| row[0] }
  end

  comma do
    customer_delivery_method(:abbreviation => 'Deliv. Meth.')
    customer_region(:name => 'Region')
    customer(:district => 'District')
    customer(:name => 'Customer')
    num_copies('Copies')
    request_date('Requested Date')
    comments('Comment')
    customer(:id => 'Customer ID')
    customer_type(:name => 'Cust. Type')
    customer_type(:description => 'Customer Type (long)')
    customer_delivery_method(:name => 'Delivery Method (long)')
    customer(:deliver_via => 'Deliver Via')
    customer(:address => 'Address')
    customer(:po_box => 'P.O. Box')
    customer(:contact_name => 'Contact Name')
    customer(:contact_position => 'Contact Position')
    customer(:telephone_1 => 'Tel.')
    customer(:telephone_2 => 'Tel. (2)')
    customer(:telephone_3 => 'Tel. (3)')
    customer(:fax => 'Fax')
    customer(:email_1 => 'Email')
    customer(:email_2 => 'Email (2)')
    customer(:website => 'Website')
  end
end
