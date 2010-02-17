module ActsAsReportableControllerHelper
  def report_table_from_objects(objects, options = {})
    if not objects or objects.empty?
      return Ruport::Data::Table.new(
        :data => [['No data found']],
        :column_names => [ 'data' ]
      )
    end

    object_class = objects.first.class

    record_class = options.delete(:record_class) || Ruport::Data::Record
    filters = options.delete(:filters)
    transforms = options.delete(:transforms)
    order = options.delete(:order)

    object_class.aar_columns = []

    data = objects.map{|o| o.reportable_data(options)}.flatten

    table = Ruport::Data::Table.new(
      :data => data,
      :column_names => object_class.aar_columns,
      :record_class => record_class,
      :filters => filters,
      :transforms => transforms
    )

    table.reorder(order) if order
  end
end
