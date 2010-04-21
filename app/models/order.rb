class Order < ActiveRecord::Base
  extend DateField

  include SoftDeletable
  versioned

  belongs_to :customer
  belongs_to :issue
  belongs_to :delivery_method
  belongs_to :region
  belongs_to :standing_order

  validates_presence_of :customer_id
  validates_presence_of :issue_id
  validates_presence_of :num_copies
  validates_presence_of :delivery_method_id
  validates_presence_of :region_id
  # Allow multiple orders per customer (e.g., different dates)
  #validates_uniqueness_of :issue_id, :scope => :customer_id
  validates_uniqueness_of :issue_id, :scope => [ :standing_order_id, :deleted_at ],
                          :if => lambda { |o| o.standing_order_id && o.deleted_at.nil? }
  validates_numericality_of :num_copies, :only_integer => true, :greater_than => 0

  date_field :order_date

  # BUG: After "new" and before "validate", the record is invalid
  before_validation :copy_data_from_customer_if_new_record

  def customer_type
    customer.try(:type)
  end

  # Returns a dictionary of { IssueBoxSize => (int) num_boxes }
  # BROKEN if the underlying Issue changes
  def num_boxes
    if @box_sizes_cache and @box_sizes_cache_num_copies == num_copies
      return @box_sizes_cache
    end

    @box_sizes_cache_num_copies = num_copies
    @box_sizes_cache = issue.issue_box_size_quantities(num_copies)
  end

  comma do
    delivery_method(:abbreviation => 'Deliv. Meth.')
    region(:name => 'Region')
    district('District')
    customer_name('Customer')
    num_copies('Copies')
    order_date('Date')
    comments('Comment')
    customer(:id => 'Customer ID')
    customer(:district => 'Current Customer district')
    customer(:name => 'Current Customer name')
    customer_type(:name => 'Cust. Type')
    customer_type(:description => 'Customer Type (long)')
    delivery_method(:name => 'Delivery Method (long)')
    deliver_via('Deliver Via')
    customer(:address => 'Customer address')
    contact_name('Contact Name')
    contact_details('Contact Details')
    customer(:contact_name => 'Current Contact Name')
    customer(:contact_position => 'Current Contact Position')
    customer(:telephone_1 => 'Tel.')
    customer(:telephone_2 => 'Tel. (2)')
    customer(:telephone_3 => 'Tel. (3)')
    customer(:fax => 'Fax')
    customer(:email_1 => 'Email')
    customer(:email_2 => 'Email (2)')
    customer(:website => 'Website')
  end

  private

  def copy_data_from_customer_if_new_record
    return if not new_record?

    self.region_id = customer.region_id
    self.district = customer.district
    self.customer_name = customer.name
    self.deliver_via = customer.delivery_instructions
    self.delivery_method_id = customer.delivery_method_id
    self.contact_name = customer.contact_name
    self.contact_details = customer.contact_details_string

    true # Do not fail
  end
end
