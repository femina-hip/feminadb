module CustomerFilterControllerMethods
  def self.included(base)
    base.before_filter :remember_q_and_page, :only => :index
  end

  private

  def customer_search(options = {})
    page = options.delete(:page) || requested_page
    per_page = options.delete(:per_page) || requested_per_page
    q = options.delete(:q) || requested_q

    customers = Customer.search do
      CustomersSearcher.apply_query_string_to_search(self, q)
      (options[:order] || []).each do |field|
        order_by(field)
      end
      paginate(:page => page, :per_page => per_page)
    end
  end

  def search_for_customers(options = {})
    # HACK: sets @search
    order = options.delete(:order) || []
    @search = customer_search(:order => order)
    customers = @search.results

    if options[:includes]
      Customer.send(:preload_associations, customers, options[:includes])
    end

    customers
  end

  def conditions
    @conditions ||= begin
      lots = 999999
      @search = customer_search(:q => (params[:q] || ''), :page => 1, :per_page => lots)
      all_ids = @search.raw_results.collect{|r| r.primary_key.to_i}
      {:customer_id => all_ids}
    end
  end

  def requested_q
    if !((params[:add_term] || '') + (params[:add_value] || '')).strip.empty?
      # FIXME ugly, untested, unnecessarily complex
      if params[:q]
        params[:q] << ' '
      else
        params[:q] = ''
      end
      if params[:add_term]
        params[:q] << params[:add_term] << ':'
      end
      add_value = params[:add_value].strip
      if add_value =~ / /
        if add_value =~ /"/
          add_value = "'#{add_value}'"
        else
          add_value = "\"#{add_value}\""
        end
      elsif add_value.strip == ''
        add_value = '""'
      end
      params[:q] << add_value
    end
    params[:q] ||= session[:customers_q]
    params[:q] || ''
  end

  def remember_q_and_page
    session[:customers_q] = params[:q] if params[:q]
    session[:customers_page] = requested_page
  end

  def requested_page
    return params[:page].to_i if params[:page].to_i > 0
    return session[:customers_page] if not params[:q]
    1
  end

  def requested_per_page
    return :all if request.format == Mime::CSV
    self.class.model_class.per_page
  end
end
