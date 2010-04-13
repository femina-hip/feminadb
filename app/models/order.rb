class Order < ActiveRecord::Base
  include SoftDeletable
  versioned
  acts_as_reportable

  belongs_to :customer
  belongs_to :issue
  belongs_to :delivery_method
  belongs_to :region
  belongs_to :standing_order
  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by

  validates_presence_of :customer_id
  validates_presence_of :issue_id
  validates_presence_of :num_copies
  validates_presence_of :delivery_method_id
  validates_presence_of :region_id
  # Allow multiple orders per customer (e.g., different dates)
  #validates_uniqueness_of :issue_id, :scope => :customer_id
  validates_uniqueness_of :issue_id, :scope => [ :standing_order_id, :deleted_at ]
                          :if => lambda { |o| o.standing_order_id && o.deleted_at.nil? }

  # BUG: After "new" and before "validate", the record is invalid
  before_validation :copy_data_from_customer_if_new_record

  # Returns a dictionary of { IssueBoxSize => (int) num_boxes }
  # BROKEN if the underlying Issue changes
  def num_boxes
    if @box_sizes_cache and @box_sizes_cache_num_copies == num_copies
      return @box_sizes_cache
    end

    @box_sizes_cache_num_copies = num_copies
    @box_sizes_cache = issue.issue_box_size_quantities(num_copies)
  end

  protected
    def validate
      errors.add(:num_copies, 'must be greater than 0') unless num_copies.to_i > 0
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
