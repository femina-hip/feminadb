# encoding: utf-8
class Order < ActiveRecord::Base
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

  # Returns a dictionary of { (int) box_size => (int) num_boxes }
  def num_boxes
    issue.find_box_sizes(num_copies)
  end

  comma do
    delivery_method('Delivery Method')
    region('Region')
    council('Council')
    customer_name('Customer')
    num_copies('Copies')
    order_date('Date')
    comments('Comment')
  end
end
