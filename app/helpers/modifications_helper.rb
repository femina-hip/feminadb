module ModificationsHelper
  def show_record_identifier(audit)
    klass = audit.table_name.singularize.classify.safe_constantize

    if audit.record_id
      klass_or_nil = audit.table_name.singularize.classify.safe_constantize
      record = klass_or_nil && klass_or_nil.find_by_id(audit.record_id) # find(id) can throw an exception. We want nil.
      if record && (record.respond_to?(:title) || record.respond_to?(:name))
        text = "#{klass.model_name.human} #{audit.record_id}: #{record.respond_to?(:title) ? record.title : record.name}"
        if record.class.respond_to?(:can_visit_url?) && record.class.can_visit_url?
          link_to(text, record)
        else
          content_tag(:span, text)
        end
      elsif record
        content_tag(:span, "#{klass.model_name.human} #{audit.record_id}")
      else
        content_tag(:span, "#{audit.table_name.singularize} #{audit.record_id}")
      end
    else
      content_tag(:span, "#{audit.table_name} #{audit.record_id || '(no ID)'}")
    end
  end

  def link_to_record_history(audit)
    link_to('history', modifications_path(:table_name => audit.table_name, :record_id => audit.record_id), :class => 'history')
  end

  def format_column_value(column_name, value)
    case column_name
      when 'customer_id' then format_customer_id(value)
      when 'customer_type_id' then format_customer_type_id(value)
      when 'delivery_method_id' then format_delivery_method_id(value)
      when 'issue_id' then format_issue_id(value)
      when 'publication_id' then format_publication_id(value)
      when 'region_id' then format_region_id(value)
      when 'tag_id' then format_tag_id(value)
      else value
    end
  end

  private

  def format_customer_id(id)
    return nil if id.nil?
    c = Customer.find_by_id(id)
    c && "#{id}: #{c.name}" || id
  end

  def format_customer_type_id(id)
    return nil if id.nil?
    ct = CustomerType.find_by_id(id)
    ct && "#{id}: #{ct.name} - #{ct.description}" || id
  end

  def format_delivery_method_id(id)
    return nil if id.nil?
    dm = DeliveryMethod.find_by_id(id)
    dm && "#{id}: #{dm.abbreviation} - #{dm.name}" || id
  end

  def format_publication_id(id)
    return nil if id.nil?
    p = Publication.find_by_id(id)
    p && "#{id}: #{p.name}" || id
  end

  def format_issue_id(id)
    return nil if id.nil?
    i = Issue.find_by_id(id)
    i && "#{id}: #{i.issue_number} - #{i.name}" || id
  end

  def format_region_id(id)
    return nil if id.nil?
    r = Region.find_by_id(id)
    r && "#{id} (#{r.name})" || id
  end

  def format_tag_id(id)
    return nil if id.nil?
    t = Tag.find_by_id(id)
    t && "#{id} (#{t.name})" || id
  end
end
