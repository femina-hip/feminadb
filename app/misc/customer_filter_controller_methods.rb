module CustomerFilterControllerMethods
  private

  AllInOnePage = 1 << 29 # some large number
  NormalPage = 50

  def search_result_customer_ids
    @search_result_customer_ids ||= begin
      search = Customer.search do
        ::QueryBuilder::apply_string_to_search(requested_q, self.instance_variable_get('@search'))
        order_by(:sort_column)
        lots = 999999
        paginate(page: 1, per_page: lots)
      end
      search.hits.collect { |h| h.primary_key.to_i }
    end
  end

  def search_result_facets
    @search_result_facets ||= begin
      search = Customer.search do
        ::QueryBuilder::apply_string_to_search(requested_q, self.instance_variable_get('@search'))

        paginate(page: 1, per_page: 1)

        facet(:category, sort: :index)
        facet(:region, sort: :index)
        facet(:council, sort: :index)
        facet(:type, sort: :index)
        facet(:delivery_method, sort: :index)
        facet(:has_headmaster_sms_number, sort: :index)
        facet(:club, sort: :index)

        Customer.publications_tracking_standing_orders_for_indexing.each do |p|
          sym = p.to_index_key.to_sym

          dynamic(:standing) { facet(sym, :sort => :index) }
        end

        facet(:tag, sort: :index)
      end
      search
    end
  end

  def conditions
    @conditions ||= { customer_id: search_result_customer_ids }
  end

  def requested_q
    params[:q] || ''
  end

  def requested_page
    return params[:page].to_i if params[:page].to_i > 0
    1
  end

  def requested_per_page
    if params[:format] == 'csv' || params[:format] == 'xlsx'
      AllInOnePage
    else
      NormalPage
    end
  end
end
