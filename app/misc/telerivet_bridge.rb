module TelerivetBridge
  MessagesPageSize = 200

  # Returns a contact ID
  def self.ensure_telerivet_contact_and_return_id(telerivet_link)
    Rails.logger.info("Project<#{project.id}>.get_or_create_contact(#{telerivet_link.sms_number})")
    project.get_or_create_contact({
      phone_number: telerivet_link.sms_number,
      lookup_key: 'phone_number',
      name: telerivet_link.telerivet_name,
      vars: {
        contact_name: telerivet_link.contact_name,
        feminadb_url: "https://db.feminahip.or.tz/customers/#{telerivet_link.customer.id}",
      }
    }).id
  end

  def self.ensure_telerivet_group_and_return_id(group_name)
    Rails.logger.info("Project<#{project.id}>.get_or_create_group(#{group_name})")
    group = project.get_or_create_group(group_name)
    group.id
  end

  def self.ensure_contact_is_in_group(contact_id, group_id)
    Rails.logger.info("Project<#{project.id}>.Contact<#{contact_id}>.add_to_group(Group<#{group_id}>)")
    project.init_contact_by_id(contact_id)
      .add_to_group(project.init_group_by_id(group_id))
  end

  def self.ensure_contact_is_not_in_group(contact_id, group_id)
    Rails.logger.info("Project<#{project.id}>.Contact<#{contact_id}>.remove_from_group(Group<#{group_id}>)")
    project.init_contact_by_id(contact_id)
      .remove_from_group(project.init_group_by_id(group_id))
  end

  def self.sync_telerivet_link_and_return_contact_id(telerivet_link)
    contact_id = ensure_telerivet_contact_and_return_id(telerivet_link)
    for group_name in telerivet_link.telerivet_groups_to_add
      group_id = ensure_telerivet_group_and_return_id(group_name)
      ensure_contact_is_in_group(contact_id, group_id)
    end
    for group_name in telerivet_link.telerivet_groups_to_remove
      group_id = ensure_telerivet_group_and_return_id(group_name)
      ensure_contact_is_not_in_group(contact_id, group_id)
    end
    contact_id
  end

  def self.unsync_telerivet_link(telerivet_link)
    Rails.logger.info("Project<#{project.id}>.get_or_create_contact(#{telerivet_link.sms_number})")
    contact = project.get_or_create_contact({
      phone_number: telerivet_link.sms_number,
      lookup_key: 'phone_number',
      name: telerivet_link.sms_number,
    })
    contact.vars.feminadb_url = "https://db.feminahip.or.tz/telerivet_links/new?sms_number=#{telerivet_link.sms_number.sub('+', '%2B')}"
    Rails.logger.info("Project<#{project.id}>.Contact<#{contact.id}>.save")
    contact.save
    contact_id = contact.id

    for group_name in (telerivet_link.telerivet_groups_to_add - [ 'Audience' ])
      group_id = ensure_telerivet_group_and_return_id(group_name)
      ensure_contact_is_not_in_group(contact_id, group_id)
    end
    for group_name in telerivet_link.telerivet_groups_to_remove
      group_id = ensure_telerivet_group_and_return_id(group_name)
      ensure_contact_is_in_group(contact_id, group_id)
    end
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
