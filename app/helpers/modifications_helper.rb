module ModificationsHelper
  def format_datetime(dt)
    dt.to_time.to_formatted_s(:short)
  end

  def show_attribute(m, a)
    case a
      when 'customer_id' then format_customer_id(m)
      when 'updated_by' then format_updated_by(m)
      when 'customer_type_id' then format_customer_type_id(m)
      when 'delivery_method_id' then format_delivery_method_id(m)
      when 'region_id' then format_region_id(m)
      else h m.send(a).to_s
    end
  end

  private
    def format_customer_id(m)
      h Customer.find_with_deleted(m.customer_id).name
    end

    def format_updated_by(m)
      'hello'
    end

    def format_customer_type_id(m)
      ct = CustomerType.find_with_deleted(m.customer_type_id)
      h "#{ct.name} - #{ct.description}"
    end

    def format_delivery_method_id(m)
      dm = DeliveryMethod.find(m.delivery_method_id)
      h "#{dm.abbreviation} - #{dm.name}"
    end

    def format_region_id(m)
      r = Region.find_with_deleted(m.region_id)
      h "#{r.name}"
    end
end
