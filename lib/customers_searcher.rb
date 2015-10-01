module CustomersSearcher
  def self.apply_query_string_to_search(search_builder, query)
    Sunspot::QueryBuilder::apply_string_to_search(query, search_builder.instance_variable_get(:@search))

    search_builder.facet(:category, :sort => :index)
    search_builder.facet(:region, :sort => :index)
    search_builder.facet(:district, :sort => :index)
    search_builder.facet(:type, :sort => :index)
    search_builder.facet(:delivery_method, :sort => :index)
    search_builder.facet(:club, :sort => :index)

    Customer.publications_tracking_standing_orders_for_indexing.each do |p|
      sym = p.to_index_key.to_sym

      search_builder.dynamic(:standing) { facet(sym, :sort => :index) }
      search_builder.dynamic(:waiting) { facet(sym, :sort => :index) }
    end
  end
end
