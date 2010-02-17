module IssuesHelper
  def issue_date_column(record)
    record.issue_date.strftime '%b %Y'
  end

  def issue_box_sizes_column(record)
    record.issue_box_sizes.collect{|ibs| String(ibs.num_copies)}.join(', ')
  end

  def print_distribution_list_url
    formatted_show_distribution_list_publication_issue_url(@publication, @issue, :pdf, params.reject{|k,v| k.to_sym != :delivery_method_id})
  end
end
