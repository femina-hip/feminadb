class Customer < ActiveRecord::Base
  NEEDS_STRIPPING = /(^\s)|(\s$)/
  extend Forwardable

  include SoftDeletable
  versioned
  acts_as_reportable

  searchable do
    integer(:region_id)
    string(:region, :stored => true) { region.name }
    string(:district, :stored => true)
    string(:name, :stored => true)
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
    boolean(:deleted) { !deleted_at.nil? }
  end

  belongs_to :type, :class_name => 'CustomerType',
             :foreign_key => 'customer_type_id'
  belongs_to :delivery_method
  belongs_to :region
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
  validates_uniqueness_of :name, :scope => [ :region_id, :district, :deleted_at ],
                          :case_sensitive => false, :if => lambda { |c| c.deleted_at.nil? }
  validates_presence_of :delivery_method_id

  before_validation :strip_string_fields
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

  def self.fuzzy_find(region_id, district, name)
    fuzz = "~0.5"
    search = Customer.search do
      with(:deleted, false)
      with(:region_id, region_id)

      adjust_solr_params do |params|
        params[:fq] ||= []
        district.split.each do |word|
          params[:fq] << "district_text:#{RSolr.escape(word.downcase)}#{fuzz}"
        end
        name.split.each do |word|
          params[:fq] << "name_text:#{RSolr.escape(word.downcase)}#{fuzz}"
        end
      end
    end
    search.raw_results
  end

  private

  def clear_deliver_via_if_same_as_name
    if deliver_via == name
      write_attribute(:deliver_via, nil)
    end
    true # Returning false will cancel save
  end

  def strip_string_fields
    if name =~ NEEDS_STRIPPING
      write_attribute(:name, name.strip)
    end
    if district =~ NEEDS_STRIPPING
      write_attribute(:district, district.strip)
    end
    if deliver_via =~ NEEDS_STRIPPING
      write_attribute(:deliver_via, deliver_via.strip)
    end
  end
end
