module TelerivetBridge
  MessagesPageSize = 200

  # Returns a contact ID
  def self.ensure_customer_sms_link_and_return_id(customer_id, sms_number)
    project.get_or_create_contact({
      phone_number: sms_number,
      lookup_key: 'phone_number',
      vars: { feminadb_url: "https://db.feminahip.or.tz/customers/#{customer_id}" }
    }).id
  end

  # Returns an Array of SmsMessages
  def self.sms_messages_for_contact_id(contact_id)
    project.query_messages(contact_id: contact_id, page_size: MessagesPageSize).map do |message|
      # The SMS number from Telerivet *might* be different from what we have,
      # if this contact has changed numbers. (We shouldn't change contacts'
      # phone numbers in Telerivet; but on the off chance we do, let's not add
      # confusion here.)
      sms_number = message.direction == 'incoming' && message.from_number || message.to_number

      SmsMessage.new(
        id: message.id,
        contact_id: contact_id,
        sms_number: sms_number,
        direction: message.direction.to_sym,
        created_at: Time.at(message.time_created),
        content: message.content || '',
        error_message: message.error_message
      )
    end
  end

  def self.url_for_contact_id(contact_id)
    "https://telerivet.com/p/#{project_id[2...10]}/contact/#{contact_id}"
  end

  def self.url_for_message_id(message_id)
    "https://telerivet.com/p/#{project_id[2...10]}/message/#{message_id}"
  end

  private

  def self.project_id; Rails.application.secrets.telerivet_project_id; end
  def self.api_key; Rails.application.secrets.telerivet_api_key; end

  def self.project
    @project ||= Telerivet::API.new(api_key).init_project_by_id(project_id)
  end
end
