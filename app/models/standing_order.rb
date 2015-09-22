# encoding: utf-8
class StandingOrder < ActiveRecord::Base
  belongs_to(:customer)
  belongs_to(:publication)

  after_save { |so| so.customer.try(:index) }

  validates_presence_of :customer_id
  validates_presence_of :publication_id
  validates_uniqueness_of :publication_id, scope: :customer_id
  validates(:num_copies, numericality: { only_integer: true, greater_than: 0 })
  validate :publication_tracks_standing_orders

  def customer_delivery_method
    customer.delivery_method
  end

  def customer_region
    customer.region
  end

  def customer_type
    customer.type
  end

  comma do
    customer_delivery_method(:abbreviation => 'Deliv. Meth.')
    customer_region(:name => 'Region')
    customer(:district => 'District')
    customer(:name => 'Customer')
    num_copies('Copies')
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

  def title
    "#{num_copies} #{publication.name} → #{customer.name}"
  end

  private

  def publication_tracks_standing_orders
    errors.add(:publication_id, 'does not track Standing Orders') unless publication.tracks_standing_orders?
  end
end
