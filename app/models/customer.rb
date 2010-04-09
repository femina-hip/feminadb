class Customer < ActiveRecord::Base
  extend Forwardable

  include SoftDeletable
  versioned
  acts_as_reportable

  searchable do
    string(:region) { region.name }
    string(:district) { (district.nil? || district.empty?) ? 'AAAAA' : district }
    string(:name) { name }
    string(:delivery_method) { delivery_method.abbreviation }
    string(:type) { type.name }
    string(:category) { type.category }
    text(:district)
    text(:name)
    text(:contact_name)
    text(:deliver_via)
    text(:address)
    text(:full_name)
    text(:contact_position)
    text(:telephone_1)
    text(:telephone_2)
    text(:telephone_3)
    text(:fax)
    text(:email_1)
    text(:email_2)
    text(:website)
    text(:po_box)
    text(:delivery_method) { delivery_method.abbreviation }
    text(:delivery_method_name) { delivery_method.name }
    text(:customer_note_text) { notes.collect(&:note).join('\n') }
    text(:region) { region.name }
    text(:type) { type.name }
    text(:type_description) { type.description }
    text(:category) { type.category }
    boolean(:club) { !club.nil? }
    Club.column_names.each do |c|
      text("club_#{c}") { club && club.send(c) }
    end
  end

  belongs_to :type, :class_name => 'CustomerType',
             :foreign_key => 'customer_type_id'
  belongs_to :delivery_method
  belongs_to :region
  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  has_many :standing_orders,
           :dependent => :destroy,
           :include => [ :publication ],
           :order => 'publications.name',
           :conditions => 'standing_orders.deleted_at IS NULL'
  has_many :waiting_orders,
           :dependent => :destroy,
           :include => [ :publication ],
           :order => 'publications.name',
           :conditions => 'waiting_orders.deleted_at IS NULL'
  has_many :orders,
           :dependent => :nullify,
           :include => { :issue => :publication },
           :order => 'publications.name, issues.issue_number DESC',
           :conditions => 'orders.deleted_at IS NULL'
  has_many :special_orders,
           :dependent => :nullify,
           :order => 'special_orders.requested_for_date DESC',
           :conditions => 'special_orders.deleted_at IS NULL'
  has_many :special_order_lines,
           :through => :special_orders,
           :source => :lines,
           :include => { :issue => :publication },
           :order => 'publications.name, issues.issue_number DESC, special_orders.requested_for_date DESC',
           :conditions => 'special_order_lines.deleted_at IS NULL'
  has_many :notes,
           :dependent => :destroy,
           :class_name => 'CustomerNote',
           :conditions => 'customer_notes.deleted_at IS NULL'
  has_one :club,
          :dependent => :destroy,
          :conditions => 'clubs.deleted_at IS NULL'

  validates_presence_of :region_id
  validates_presence_of :customer_type_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :region_id, :district ],
                          :case_sensitive => false
  validates_presence_of :delivery_method_id

  before_validation :clear_deliver_via_if_same_as_name

  def self.can_visit_url?; true; end

  def deliver_via_string
    (deliver_via and not deliver_via.empty? and deliver_via != name) ? "via #{deliver_via}" : nil
  end

  def delivery_instructions
    [ deliver_via_string, address ].reject{|x| x.nil?}.join(', ')
  end

  def contact_details_string
    [ telephone_1, email_1, telephone_2, email_2, telephone_3, fax ].select{|x| not x.nil? }[0..2].join(', ')
  end

  private

  def clear_deliver_via_if_same_as_name
    if deliver_via == name
      write_attribute :deliver_via, nil
    end
    true # Returning false will cancel save
  end
end
