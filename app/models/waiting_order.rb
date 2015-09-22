# encoding: utf-8
class WaitingOrder < ActiveRecord::Base
  extend DateField

  include SoftDeletable
  #versioned

  belongs_to(:customer)
  belongs_to(:publication)

  after_save { |wo| wo.customer.try(:index) }

  validates_presence_of :customer_id
  validates_presence_of :publication_id
  validates_presence_of :request_date
  validates_uniqueness_of :publication_id, :scope => [ :customer_id, :deleted_at ], :if => lambda { |wo| wo.deleted_at.nil? }
  validates_numericality_of :num_copies, :only_integer => true, :greater_than => 0

  date_field :request_date

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

  # Returns a standing order and soft-deletes this waiting order
  #
  # Returns nil if the standing order couldn't be created
  def convert_to_standing_order(options = {})
    standing_order = nil
    transaction do
      standing_order = StandingOrder.new(options.merge(
        :customer_id => customer_id,
        :publication_id => publication_id,
        :num_copies => num_copies,
        :comments => "From Waiting Order #{request_date.to_formatted_s(:long)}: #{comments}"
      ))
      return nil unless standing_order.save
      soft_delete(options.slice(:updated_by))
    end
    standing_order
  end

  def title
    "#{num_copies} #{publication.name} → #{customer.name}"
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
