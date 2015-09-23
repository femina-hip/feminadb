module IssuesHelper
  def issue_date_column(record)
    record.issue_date.strftime '%b %Y'
  end

  def issue_box_sizes_column(record)
    record.issue_box_sizes.collect{|ibs| String(ibs.num_copies)}.join(', ')
  end

  def print_distribution_list_url
    show_distribution_list_issue_url(@issue, params.slice(:delivery_method_id).merge(:format => :pdf))
  end
end
