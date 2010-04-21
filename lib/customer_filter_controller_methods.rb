module CustomerFilterControllerMethods
  private

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

  def requested_page
    return params[:page].to_i if params[:page].to_i > 0
    1
  end

  def requested_per_page
    return :all if request.format == Mime::CSV
    self.class.model_class.per_page
  end
end
