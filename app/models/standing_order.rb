class StandingOrder < ActiveRecord::Base
  acts_as_paranoid_versioned
  acts_as_reportable

  belongs_to :customer
  belongs_to :publication
  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by

  validates_presence_of :customer_id
  validates_presence_of :publication_id
  validates_uniqueness_of :publication_id, :scope => :customer_id
  validates_inclusion_of :num_copies, :in => 1..9999999, :message => 'must be greater than 0'
  validate :publication_tracks_standing_orders

  def create_order_for_issue!(issue)
    order_date = DateTime.now()
    contact_details = [ customer.telephone_1, customer.telephone_2, customer.telephone_3, customer.fax, customer.email_1, customer.email_2 ].reject{ |x| x.nil? or x.strip.empty? }.join('; ')

    Order.create!({
          :customer_id => customer_id,
          :region_id => customer.region_id,
          :district => customer.district,
          :customer_name => customer.name,
          :deliver_via => customer.deliver_via,
          :delivery_method_id => customer.delivery_method_id,
          :contact_name => customer.contact_name,
          :contact_details => contact_details,
          :issue_id => issue.id,
          :standing_order_id => id,
          :num_copies => num_copies,
          :comments => 'Automatic from Standing Order',
          :order_date => order_date
          })
  end

  private
    def publication_tracks_standing_orders
      errors.add(:publication_id, 'does not track Standing Orders') unless publication.tracks_standing_orders?
    end
end
