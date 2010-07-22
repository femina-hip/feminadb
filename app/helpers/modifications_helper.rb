module ModificationsHelper
  # Returns, from a Version, an Array of [column, [old, new]]
  def display_ready_changes_for_version(version)
    hash = if version.initial?
      record = version.versioned
      record.revert_to(version)
      returning({}) do |h|
        record.attributes.each do |k, v|
          h[k] = [nil, v]
        end
      end
    else
      version.changes
    end

    hash.keys.sort.collect{|k| [k, hash[k]]}
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

  def format_column_value(column_name, value)
    case column_name
      when 'customer_id' then format_customer_id(value)
      when 'customer_type_id' then format_customer_type_id(value)
      when 'delivery_method_id' then format_delivery_method_id(value)
      when 'region_id' then format_region_id(value)
      else value
    end
  end

  private

  def format_customer_id(id)
    c = Customer.find_by_id(id)
    c && "#{id} (#{c.name})" || id
  end

  def format_customer_type_id(id)
    ct = CustomerType.find_by_id(id)
    ct && "#{id} (#{ct.name} - #{ct.description})" || id
  end

  def format_delivery_method_id(id)
    dm = DeliveryMethod.find_by_id(id)
    dm && "#{id} (#{dm.abbreviation} - #{dm.name})" || id
  end

  def format_region_id(id)
    r = Region.find_by_id(id)
    r && "#{id} (#{r.name})" || id
  end
end
