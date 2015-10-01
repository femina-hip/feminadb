class SmsMessage
  include ActiveModel::Model
  attr_accessor(:id, :contact_id, :sms_number, :created_at, :direction, :content, :error_message)
  # "direction" is either :incoming or :outgoing

  def url; TelerivetBridge.url_for_message_id(id); end
  def contact_url; TelerivetBridge.url_for_contact_id(contact_id); end
end
