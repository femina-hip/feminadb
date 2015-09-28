module TelerivetBridge
  def self.ensure_customer_sms_link(customer_id, sms_number)
    project.get_or_create_contact({
      phone_number: sms_number,
      lookup_key: 'phone_number',
      vars: { feminadb_url: "https://db.feminahip.or.tz/customers/#{customer_id}" }
    })
  end

  private

  def self.project_id; Rails.application.secrets.telerivet_project_id; end
  def self.api_key; Rails.application.secrets.telerivet_api_key; end

  def self.project
    @project ||= Telerivet::API.new(api_key).init_project_by_id(project_id)
  end
end
