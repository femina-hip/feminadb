module CustomerFilterControllerMethods
  def self.included(base)
    base.before_filter :remember_q_and_page, :only => :index
  end

  private

  def search_for_customers(options = {})
    page = requested_page
    per_page = requested_per_page
    q = requested_q

    customers = Customer.search do
      CustomersSearcher.apply_query_string_to_search(self, q)
      (options[:order] || []).each do |field|
        order_by(field)
      end
      paginate(:page => page, :per_page => per_page)
    end.results

    if options[:includes]
      Customer.send(:preload_associations, customers, options[:includes])
    end

    customers
  end

  def conditions
    @conditions ||= if params[:q]
      q = params[:q]
      lots = 999999
      all_ids = Customer.search_ids do
        CustomersSearcher.apply_query_string_to_search(self, q)
        paginate(:page => 1, :per_page => lots)
      end
      {:customer_id => all_ids}
    else
      {}
    end
  end

  def requested_q
    params[:q] ||= session[:customers_q]
    params[:q] || ''
  end

  def remember_q_and_page
    session[:customers_q] = params[:q] if params[:q]
    session[:customers_page] = requested_page
  end

  def requested_page
    return params[:page].to_i if params[:page].to_i > 0
    1
  end

  def requested_per_page
    return :all if request.format == Mime::CSV
    self.class.model_class.per_page
  end
end
