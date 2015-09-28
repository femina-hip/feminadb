class Customer < ActiveRecord::Base
  NEEDS_STRIPPING = /(^\s)|(\s$)/
  extend Forwardable

  # Controllers index manually whenever anything might have changed.
  searchable(
      auto_index: false,  # controllers handle indexing
      auto_remove: false, # controllers handle indexing
      include: [
        { standing_orders: :publication },
        { waiting_orders: :publication },
        :region,
        :delivery_method,
        :type,
        :club,
        :notes
      ]
    ) do
    integer(:id)
    integer(:region_id)
    date(:created_at)
    string(:region, :stored => true) { region.name }
    string(:district, :stored => true)
    string(:name, :stored => true)
    string(:delivery_method) { delivery_method.abbreviation }
    string(:type) { type.name }
    string(:category) { type.category }
    text(:district)
    text(:name)
    text(:contact_name)
    text(:delivery_address)
    text(:sms_numbers)
    text(:club_sms_numbers)
    text(:student_sms_numbers)
    text(:old_sms_numbers)
    text(:old_club_sms_numbers)
    text(:other_contacts)
    text(:delivery_method) { delivery_method.abbreviation }
    text(:delivery_method_name) { delivery_method.name }
    text(:customer_note_text) { notes.collect(&:note).join("\n") }
    text(:standing_order_comments) { standing_orders.collect(&:comments).join("\n") }
    text(:waiting_order_comments) { waiting_orders.collect(&:comments).join("\n") }
    text(:region) { region.name }
    text(:type) { type.name }
    text(:type_description) { type.description }
    text(:category) { type.category }
    boolean(:club) { has_club? }
    dynamic_integer(:standing_num_copies) do
      publications_tracking_standing_orders_for_indexing.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = standing_order_for(publication).try(:num_copies) || 0
        hash.merge!(key => value)
      end
    end
    dynamic_integer(:waiting_num_copies) do
      publications_tracking_standing_orders_for_indexing.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = waiting_order_for(publication).try(:num_copies) || 0
        hash.merge!(key => value)
      end
    end
    dynamic_date(:created_standing) do
      publications_tracking_standing_orders_for_indexing.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = standing_order_for(publication).try(:created_at)
        hash.merge!(key => value)
      end
    end
    dynamic_date(:requested_waiting) do
      publications_tracking_standing_orders_for_indexing.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = waiting_order_for(publication).try(:request_date)
        hash.merge!(key => value)
      end
    end
    dynamic_boolean(:standing) do
      publications_tracking_standing_orders_for_indexing.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = standing_order_for(publication) && true || false
        hash.merge!(key => value)
      end
    end
    dynamic_boolean(:waiting) do
      publications_tracking_standing_orders_for_indexing.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = waiting_order_for(publication) && true || false
        hash.merge!(key => value)
      end
    end
  end

  belongs_to(:type, class_name: 'CustomerType', foreign_key: 'customer_type_id')
  belongs_to(:delivery_method)
  belongs_to(:region)
  has_many(:notes, class_name: 'CustomerNote')
  has_many(:standing_orders)
  has_many(:waiting_orders)
  has_many(:orders)

  validates_presence_of :region_id
  validates_presence_of :customer_type_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :region_id, :district ], :case_sensitive => false
  validates_presence_of :delivery_method_id
  validates_format_of :sms_numbers, :club_sms_numbers, :old_sms_numbers, :old_club_sms_numbers, :student_sms_numbers,
    with: /\A(\+\d+(,\s*\+\d+)*)?\z/,
    message: '%{value} must look like "+255123456789, +255234567890"'

  before_validation :strip_string_fields

  def self.can_visit_url?; true; end
  def title; name; end
  def has_club?; !club_sms_numbers.empty?; end

  def standing_orders_hash
    @standing_orders_hash ||= standing_orders.index_by(&:publication_id)
  end

  def standing_order_for(publication)
    standing_orders_hash[publication.id]
  end

  def waiting_orders_hash
    @waiting_orders_hash ||= waiting_orders.index_by(&:publication_id)
  end

  def waiting_order_for(publication)
    waiting_orders_hash[publication.id]
  end

  def self.fuzzy_find(region_id, district, name)
    fuzz = "~0.5"
    search = Customer.search do
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

  comma do
    id('ID')
    region(:name => 'Region')
    district('District')
    type(:name => 'Type', :description => 'Type (long)')
    name('Name')
    delivery_address('Delivery address')
    sms_numbers('SMS numbers')
    club_sms_numbers('Club SMS numbers')
    other_contacts('Other contacts')
  end

  private

  def strip_string_fields
    if name =~ NEEDS_STRIPPING
      write_attribute(:name, name.strip)
    end
    if district =~ NEEDS_STRIPPING
      write_attribute(:district, district.strip)
    end
    if delivery_address =~ NEEDS_STRIPPING
      write_attribute(:delivery_address, delivery_address.strip)
    end
  end

  def self.publications_tracking_standing_orders_for_indexing
    @@publications_tracking_standing_orders_for_indexing ||= Publication.tracking_standing_orders.all
  end
end
