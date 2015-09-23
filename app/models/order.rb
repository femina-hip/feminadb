# encoding: utf-8
class Order < ActiveRecord::Base
  extend DateField

  belongs_to(:customer) # nullable
  belongs_to(:standing_order) # nullable
  belongs_to(:issue)

  validates_presence_of :issue_id
  validates_presence_of :delivery_method
  validates_presence_of :region
  validates_presence_of :customer_name
  validates_presence_of :num_copies
  validates_presence_of :order_date
  validates(:num_copies, numericality: { only_integer: true, greater_than: 0 })

  date_field :order_date

  def title
    "#{num_copies} #{publication_name} #{issue_number} → #{customer_name} on #{order_date.to_date.to_formatted_s(:long)}"
  end

  def publication_name
    issue && issue.publication_name || '???'
  end

  def issue_number
    issue && issue.issue_number || '???'
  end

  def issue_name
    issue && issue.name || '???'
  end

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
    delivery_method('Delivery Method')
    region('Region')
    district('District')
    customer_name('Customer')
    num_copies('Copies')
    order_date('Date')
    comments('Comment')
    delivery_address('Delivery address')
    contact_details('Contact Details')
  end
end
