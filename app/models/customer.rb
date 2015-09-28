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
    text(:full_name)
    text(:contact_position)
    text(:telephone_1)
    text(:telephone_2)
    text(:telephone_3)
    text(:fax)
    text(:email_1)
    text(:email_2)
    text(:website)
    text(:delivery_method) { delivery_method.abbreviation }
    text(:delivery_method_name) { delivery_method.name }
    text(:customer_note_text) { notes.collect(&:note).join("\n") }
    text(:standing_order_comments) { standing_orders.collect(&:comments).join("\n") }
    text(:waiting_order_comments) { waiting_orders.collect(&:comments).join("\n") }
    text(:region) { region.name }
    text(:type) { type.name }
    text(:type_description) { type.description }
    text(:category) { type.category }
    boolean(:club) { !club.nil? }
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
    Club.columns.each do |c|
      if c.text?
        text("club_#{c.name}") { club.try(c.name) }
      end
    end
    date(:club_created_at) { club.try(:created_at) }
  end

  belongs_to(:type, class_name: 'CustomerType', foreign_key: 'customer_type_id')
  belongs_to(:delivery_method)
  belongs_to(:region)
  has_one(:club)
  has_many(:notes, class_name: 'CustomerNote')
  has_many(:standing_orders)
  has_many(:waiting_orders)
  has_many(:orders)

  #has_many :standing_orders,
  #         :dependent => :destroy,
  #         :include => [ :publication ],
  #         :order => 'publications.name',
  #         :conditions => 'standing_orders.deleted_at IS NULL AND publications.deleted_at IS NULL'
  #has_many :waiting_orders,
  #         :dependent => :destroy,
  #         :include => [ :publication ],
  #         :order => 'publications.name',
  #         :conditions => 'waiting_orders.deleted_at IS NULL AND publications.deleted_at IS NULL'
  #has_many :orders,
  #         :dependent => :nullify,
  #         :include => [ :delivery_method, { :issue => :publication } ],
  #         :order => 'publications.name, issues.issue_date DESC',
  #         :conditions => 'orders.deleted_at IS NULL AND issues.deleted_at IS NULL AND publications.deleted_at IS NULL'

  validates_presence_of :region_id
  validates_presence_of :customer_type_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :region_id, :district ], :case_sensitive => false
  validates_presence_of :delivery_method_id

  before_validation :strip_string_fields

  def self.can_visit_url?; true; end
  def title; name; end

  def contact_details_string
    [ telephone_1, email_1, telephone_2, email_2, telephone_3, fax ].select{|x| not x.nil? }[0..2].join(', ')
  end

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
    contact_name('Contact Name')
    contact_position('Contact Position')
    telephone_1('Tel.')
    telephone_2('Tel. (2)')
    telephone_3('Tel. (3)')
    fax('Fax')
    email_1('Email')
    email_2('Email (2)')
    website('Website')
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
