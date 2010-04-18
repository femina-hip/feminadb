module Forms::ApplicationHelper
  def region_field(object_name, method, options = {})
    select(object_name, method, Region.active.order(:name).all.collect{|r| [r.name, r.id]}, options)
  end

  def customer_type_field(object_name, method, options = {})
    select(object_name, method, CustomerType.active.order(:name).all.collect{|ct| ["#{ct.name}: #{ct.description}", ct.id]}, options)
  end

  def date_field(object_name, method, options = {})
    text_field(object_name, "#{method}_string", forms_application_helper_add_class_to_options(options, 'date_field'))
  end

  def warehouse_field(object_name, method, options = {})
    select(object_name, method, Warehouse.order(:name).all.collect{|w| [w.name, w.id]}, options)
  end

  def delivery_method_field(object_name, method, options = {})
    collection_select(object_name, method, DeliveryMethod.active.order(:abbreviation), :id, :full_name, options)
  end

  # issue field
  #
  # Options:
  #  :conditions: extra conditions for search
  def issue_field(object_name, method, options = {})
    issues = Issue.active.includes(:publication).order(['issues.issue_number DESC', 'publications.name'])
    if conditions = options.delete(:conditions)
      issues = issues.where(conditions)
    end

    select_options = issues.all.collect{|i| ["[#{i.publication.name}] #{i.number_and_name}", i.id]}

    select(object_name, method, select_options, {}, forms_application_helper_add_class_to_options(options, 'issue_field'))
  end

  private

  def forms_application_helper_add_class_to_options(options, klass)
    if options[:class]
      options.merge(:class => "#{options[:class]} #{klass}")
    elsif options['class']
      options.merge('class' => "#{options['class']} #{klass}")
    else
      options.merge(:class => klass)
    end
  end
end
