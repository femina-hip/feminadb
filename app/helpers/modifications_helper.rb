module ModificationsHelper
  def format_datetime(dt)
    dt.to_time.to_formatted_s(:short)
  end

  def show_record_identifier(record)
    s = "#{record.class.model_name.human} #{record.id}"
    if record.class.respond_to?(:can_visit_url?) && record.class.can_visit_url?
      link_to(s, record)
    else
      s
    end
  end

  def link_to_record_history(record)
    link_to('history', modifications_path(:versioned_type => record.class.model_name, :versioned_id => record.id), :class => 'history')
  end

  def show_attribute(record, column)
    case column
      when 'customer_id' then format_customer_id(record)
      when 'updated_by' then format_updated_by(record)
      when 'customer_type_id' then format_customer_type_id(record)
      when 'delivery_method_id' then format_delivery_method_id(record)
      when 'region_id' then format_region_id(record)
      else h record.send(column).to_s
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
