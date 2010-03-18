module Forms::ApplicationHelper
  def region_field(object_name, method, options = {})
    select(object_name, method, Region.where(:deleted_at => nil).order(:name).all.collect{|r| [r.name, r.id]}, options)
  end

  def customer_type_field(object_name, method, options = {})
    select(object_name, method, CustomerType.where(:deleted_at => nil).order(:name).all.collect{|ct| ["#{ct.name}: #{ct.description}", ct.id]}, options)
  end

  def date_field(object_name, method, options = {})
    text_field(object_name, "#{method}_string", :class => 'date_field')
  end

  def warehouse_field(object_name, method, options = {})
    select(object_name, method, Warehouse.order(:name).all.collect{|w| [w.name, w.id]})
  end
end
