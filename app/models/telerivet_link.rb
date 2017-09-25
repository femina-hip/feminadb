class TelerivetLink
  include ActiveModel::Model
  attr_accessor :customer, :attribute, :sms_number, :contact_name

  validates :customer, :attribute, :sms_number, presence: true
  validates :sms_number, format: { with: /\A\+\d+\z/, message: 'Must look like "+255123456789"' }

  def attribute_data(override_attribute = nil)
    Customer.SMS_NUMBER_FIELDS[(override_attribute || attribute).to_sym]
  end

  # Returns the name for Telerivet.
  #
  # For instance:
  # * "VETA" => "VETA Mara Mentor"
  # * "Arusha" => "Arusha SS HoS"
  # * "TANWAT" => "TANWAT"
  # * +255123123123
  def telerivet_name
    case attribute_data[:telerivet_name]
    when :name then customer ? customer.name : ''
    when :school_headmaster then "#{customer_name_and_type_if_ss} HoS"
    when :school_mentor then "#{customer_name_and_type_if_ss} Mentor"
    # we don't change Telerivet data when adding an expired contact. We _just_
    # link to Telerivet.
    when :expired then nil
    else sms_number
    end
  end

  # Returns customer.name ... unless this is a secondary school, in which
  # case it returns "#{customer.name} SS"
  def customer_name_and_type_if_ss
    type_name = customer.type.name.split(/\s/).first
    if type_name == 'SS'
      "#{customer.name} SS"
    elsif type_name == customer.name
      # "VETA" is the customer type and name. Output "VETA Mara".
      # (This doesn't apply if the customer name is already "VETA Mara".)
      "#{customer.name} #{customer.region.name}"
    else
      customer.name
    end
  end

  def telerivet_groups_to_add
    telerivet_group_list('+')
  end

  def telerivet_groups_to_remove
    telerivet_group_list('-')
  end

  private

  # From ([ '+Audience', '+Fema REGION', '-ex-Fema' ], '+'), returns
  # [ 'Audience', 'Fema Dodoma' ].
  def telerivet_group_list(plus_or_minus, override_attribute = nil)
    attribute_data(override_attribute)[:telerivet_groups]
      .select { |s| s[0] == plus_or_minus }
      .map { |s| s.sub(plus_or_minus, '') }
      .map { |s| s.sub('REGION', customer.region.name) }
  end
end
