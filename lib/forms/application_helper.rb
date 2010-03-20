module Forms::ApplicationHelper
  def region_field(object_name, method, options = {})
    select(object_name, method, Region.where(:deleted_at => nil).order(:name).all.collect{|r| [r.name, r.id]}, options)
  end

  def customer_type_field(object_name, method, options = {})
    select(object_name, method, CustomerType.where(:deleted_at => nil).order(:name).all.collect{|ct| ["#{ct.name}: #{ct.description}", ct.id]}, options)
  end

  def date_field(object_name, method, options = {})
    text_field(object_name, "#{method}_string", forms_application_helper_add_class_to_options(options, 'date_field'))
  end

  def warehouse_field(object_name, method, options = {})
    select(object_name, method, Warehouse.order(:name).all.collect{|w| [w.name, w.id]})
  end

  def issue_field(object_name, method, options = {})
    select(object_name, method, Issue.where(:deleted_at => nil).includes(:publication).order(['issues.issue_number', 'publications.name']).all.collect{|i| ["[#{i.publication.name}] #{i.number_and_name}", i.id]}, {}, forms_application_helper_add_class_to_options(options, 'issue_field'))
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
