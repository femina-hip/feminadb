class TelerivetLink
  include ActiveModel::Model
  attr_accessor :customer, :attribute, :sms_number, :contact_name

  validates :customer, :attribute, :sms_number, presence: true
  validates :sms_number, format: { with: /\A\+\d+\z/, message: 'Must look like "+255123456789"' }

  def attribute_data(override_attribute = nil)
    Customer.SMS_NUMBER_FIELDS[(override_attribute || attribute).to_sym]
  end

  def telerivet_name
    case attribute_data[:telerivet_name]
    when :name then customer ? customer.name : ''
    when :school_headmaster then "#{customer.name} #{customer.type.name.split(/\s/)[0]} HoS"
    when :school_mentor then "#{customer.name} #{customer.type.name.split(/\s/)[0]} Club Mentor"
    else sms_number
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
