class Customer < ActiveRecord::Base
  NEEDS_STRIPPING = /(^\s)|(\s$)/
  @@SMS_NUMBER_FIELDS = {
    primary_contact_sms_numbers: {
      person: 'Primary contact',
      singular: 'Main contact SMS number',
      plural: 'Main contact SMS numbers',
      telerivet_name: :name,
      telerivet_groups: [
        '+Audience',
      ],
    },
    headmaster_sms_numbers: {
      person: 'Headmaster',
      singular: 'Headmaster SMS number',
      plural: 'Headmaster SMS numbers',
      telerivet_name: :school_headmaster,
      telerivet_groups: [
        '+Audience',
        '+Heads of School REGION',
        '-Ex-Heads of School',
      ],
    },
    club_sms_numbers: {
      person: 'Club Mentor',
      singular: 'Club Mentor SMS number',
      plural: 'Club Mentor SMS numbers',
      telerivet_name: :school_mentor,
      telerivet_groups: [
        '+Audience',
        '+Fema Club Mentors REGION',
        '-Ex-Fema Club Mentors',
      ],
    },
    old_sms_numbers: {
      person: 'Expired Contact',
      singular: 'SMS number that no longer applies',
      plural: 'SMS numbers that no longer apply',
      telerivet_name: :expired,
      telerivet_groups: [
        '+Audience',
      ],
    },
  }
  cattr_reader(:SMS_NUMBER_FIELDS)

  def self.publications_tracking_standing_orders_for_indexing
    Publication.tracking_standing_orders.all
  end

  # Controllers index manually whenever anything might have changed.
  searchable(
      auto_index: false,  # controllers handle indexing
      auto_remove: false, # controllers handle indexing
      include: [
        :notes,
        { region: :delivery_method },
        :standing_orders,
        :tags,
        :type
      ]
    ) do
    integer(:id)
    integer(:region_id)
    date(:created_at)
    string(:region) { region.name }
    string(:council, stored: true)
    boolean(:council_valid) { council_valid? }
    string(:delivery_method) { delivery_method.abbreviation }
    string(:category) { type.category }
    text(:region_manager) { region.manager }
    string(:name, stored: true) # for autocomplete, skip DB hit
    text(:name) # for search
    string(:sort_column) { [ region.name, council, name ].join("\0") }
    string(:tag, multiple: true) { tags.map(&:name) }
    text(:primary_contact_sms_numbers)
    text(:club_sms_numbers)
    text(:old_sms_numbers)
    text(:headmaster_sms_numbers)
    text(:customer_note_text) { notes.collect(&:note).join("\n") }
    string(:type) { type.name }
    text(:type_description) { type.description }
    text(:category) { type.category }
    boolean(:has_headmaster_sms_number) { !headmaster_sms_numbers.blank? }
    boolean(:club) { has_club? }

    pubs = Customer.publications_tracking_standing_orders_for_indexing
    dynamic_integer(:standing_num_copies) do
      pubs.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = standing_order_for(publication).try(:num_copies) || 0
        hash.merge!(key => value)
      end
    end
    dynamic_boolean(:standing) do
      pubs.inject({}) do |hash, publication|
        key = publication.to_index_key
        value = standing_order_for(publication) && true || false
        hash.merge!(key => value)
      end
    end
  end

  belongs_to(:type, class_name: 'CustomerType', foreign_key: 'customer_type_id')
  belongs_to(:region)
  has_many(:notes, class_name: 'CustomerNote')
  has_many(:orders)
  has_many(:standing_orders)
  has_many(:survey_responses, -> { order(end_date: :desc) }, dependent: :nullify)
  has_and_belongs_to_many(:tags, dependent: :delete, readonly: true, order: :name)

  validates_presence_of :region_id
  validates_presence_of :council
  validates_presence_of :customer_type_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :region_id, :council ], :case_sensitive => false
  validates_format_of *@@SMS_NUMBER_FIELDS.keys,
    with: /\A(\+\d+(,\s*\+\d+)*)?\z/,
    message: '%{value} must look like "+255123456789, +255234567890"'
  serialize :telerivet_id_cache, Hash

  before_validation :strip_string_fields

  def self.can_visit_url?; true; end
  def title; name; end
  def has_club?; club_sms_numbers.present?; end
  def council_valid?; region.councils.include?(council); end
  def delivery_method; region.delivery_method; end # better than has_one-through, because there's only one way to preload it
  def attributes
    super.merge(tag_names_comma_separated: tag_names_comma_separated)
  end

  # Adds an SMS number to the specified field, ensuring there is a link for the
  # SMS number in Telerivet.
  #
  # This method is safe: it will verify all parameters before writing them.
  def add_sms_number(telerivet_link)
    tl = telerivet_link
    # cache the ID for later telerivet_contact_ids calls. But don't use "||="
    # here: we need to call TelerivetBridge no matter what.
    telerivet_id_cache[tl.sms_number] = TelerivetBridge.sync_telerivet_link_and_return_contact_id(tl)
    assign_attributes(tl.attribute.to_sym => split_sms_numbers(tl.attribute.to_sym).push(tl.sms_number).uniq.join(', '))
  end

  # Removes an SMS number from the specified field.
  #
  # This method is safe: it will verify all parameters before writing them.
  def remove_sms_number(telerivet_link)
    attribute = telerivet_link.attribute
    sms_number = telerivet_link.sms_number

    TelerivetBridge.unsync_telerivet_link(telerivet_link)
    assign_attributes(attribute => split_sms_numbers(attribute).reject{ |sms| sms == sms_number }.join(', '))
  end

  # Returns the SMS numbers as an Array of Strings.
  def split_sms_numbers(attribute)
    (attributes[attribute.to_s] || '')
      .split(/,\s*/)
      .reject(&:empty?)
  end

  def standing_orders_hash
    @standing_orders_hash ||= standing_orders.index_by(&:publication_id)
  end

  def standing_order_for(publication)
    standing_orders_hash[publication.id]
  end

  def standing_order_string_for(publication)
    s = standing_order_for(publication).try(:num_copies)
    if s
      s.to_s
    else
      ''
    end
  end

  def self.fuzzy_find(region_id, name)
    search = Customer.search do
      with(:region_id, region_id)
      any do
        name.split.each do |name|
          fulltext("#{name}~", fields: [ :name ])
        end
      end
      paginate(per_page: 10)
    end
    search.raw_results
  end

  comma do
    id('ID')
    region(:name => 'Region')
    council('Council')
    type(:name => 'Type', :description => 'Type (long)')
    name('Name')
    delivery_address('Delivery Address')
    primary_contact_sms_numbers('Primary Contact SMS numbers')
    headmaster_sms_numbers('Headmaster SMS numbers')
    club_sms_numbers('Club SMS numbers')
    tag_names_comma_separated('Tags')
  end

  def self.as_xlsx(customers)
    p = Axlsx::Package.new
    p.workbook.add_worksheet(name: 'Customers') do |sheet|
      header = customers.first.to_comma_headers
      types = header.map { |x| :string }
      sheet.add_row(header)
      customers.each { |customer| sheet.add_row(customer.to_comma, types: types) }
      sheet.column_widths(*(header.map { |x| nil }))
      sheet.auto_filter = "A1:#{'ABCDEFGHIJKLMNOPQRSTUVWZYX'[header.length - 1]}1"
      sheet.sheet_view.pane do |pane|
        pane.top_left_cell = 'B2'
        pane.state = :frozen_split
        pane.y_split = 1
        pane.active_pane = :bottom_right
      end
    end
    p.use_shared_strings = true
    p.to_stream
  end

  # Returns all Telerivet contact IDs for all SMS numbers.
  def telerivet_contact_ids
    @@SMS_NUMBER_FIELDS.keys
      .map { |attribute| split_sms_numbers(attribute) }
      .flatten
      .map { |sms_number| telerivet_id_cache[sms_number] }
      .reject(&:blank?)
      .uniq
  end

  # Returns an Array of SmsMessages, sorted by created_at descending.
  #
  # We'll fetch 200 messages per contact (this is set in TelerivetBridge). That
  # should cover all the messages. So if we have five contacts (a reasonable
  # 95th percentile), that's 1,000 messages, which should be quick to sort.
  #
  # This sends off a number of API requests, so it may take some time.
  def sms_messages
    telerivet_contact_ids
      .map { |contact_id| TelerivetBridge.sms_messages_for_contact_id(contact_id) }
      .flatten
      .sort { |a, b| b.created_at - a.created_at }
  end

  # Given an SMS number, returns which field it's from
  def sms_number_attribute(sms_number)
    # Sometimes Telerivet will return SMS numbers without a "+". When we figure
    # out why, remove this workaround.
    if sms_number[0] != '+'
      sms_number = "+#{sms_number}"
    end

    @sms_number_attribute_cache ||= {}
    @sms_number_attribute_cache[sms_number] ||= @@SMS_NUMBER_FIELDS.keys
      .find { |attribute| split_sms_numbers(attribute).include?(sms_number) }
  end

  def tag_names
    tags.map(&:name)
  end

  def tag_names_comma_separated
    tag_names.join(',')
  end

  private

  def strip_string_fields
    if name =~ NEEDS_STRIPPING
      write_attribute(:name, name.strip)
    end
    if council =~ NEEDS_STRIPPING
      write_attribute(:council, council.strip)
    end
    if delivery_address =~ NEEDS_STRIPPING
      write_attribute(:delivery_address, delivery_address.strip)
    end
  end
end
