module CustomerFilterControllerMethods
  private

  AllInOnePage = 1 << 29 # some large number
  NormalPage = 50

  def customer_search(options = {}, &block)
    page = options.delete(:page) || requested_page
    per_page = options.delete(:per_page) || requested_per_page
    q = options.delete(:q) || requested_q

    customers = Customer.search do
      if block_given?
        instance_eval(&block)
      end

      ::CustomersSearcher.apply_query_string_to_search(self, q)
      (options[:order] || []).each do |field|
        order_by(field)
      end
      paginate(:page => page, :per_page => per_page)
    end
  end

  def search_for_customers(options = {}, &block)
    # HACK: sets @search
    order = options.delete(:order) || []
    @search = customer_search(:order => order, &block)
    customers = @search.results

    if options[:includes]
      ActiveRecord::Associations::Preloader.new.preload(customers, options[:includes])
    end

    customers
  end

  def search_result_customer_ids
    @search_result_customer_ids ||= begin
      search = Customer.search do
        order_by(:sort_column)
        lots = 999999
        paginate(page: 1, per_page: lots)
      end
      ::QueryBuilder::apply_string_to_search(requested_q, search)
      search.hits.collect { |h| h.primary_key.to_i }
    end
  end

  def search_result_facets
    @search_result_facets ||= begin
      search = Customer.search do
        paginate(page: 1, per_page: 1)

        facet(:category, :sort => :index)
        facet(:region, :sort => :index)
        facet(:council, :sort => :index)
        facet(:type, :sort => :index)
        facet(:delivery_method, :sort => :index)
        facet(:club, :sort => :index)

        Customer.publications_tracking_standing_orders_for_indexing.each do |p|
          sym = p.to_index_key.to_sym

          dynamic(:standing) { facet(sym, :sort => :index) }
        end
      end
      ::QueryBuilder::apply_string_to_search(requested_q, search)
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
    if request.media_type == 'text/csv'
      AllInOnePage
    else
      NormalPage
    end
  end
end
