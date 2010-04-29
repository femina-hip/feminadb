module CustomersSearcher
  def self.apply_query_string_to_search(search_builder, query)
    search_builder.with(:deleted, false)

    Sunspot::QueryBuilder::apply_string_to_search(query, search_builder.instance_variable_get(:@search))

    search_builder.facet(:region)
    search_builder.facet(:type)
    search_builder.facet(:delivery_method)
    search_builder.facet(:club)
  end

  def self.s_to_comparator_sym(s)
    case s
    when '>' then :greater_than
    when '<' then :less_than
    else :equal_to
    end
  end
end
