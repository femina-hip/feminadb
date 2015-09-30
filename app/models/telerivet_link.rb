class TelerivetLink
  include ActiveModel::Model
  attr_accessor :customer_id, :attribute, :sms_number

  validates :customer_id, :attribute, :sms_number, presence: true
  validates :sms_number, format: { with: /\A\+\d+\z/, message: 'Must look like "+255123456789"' }
end
