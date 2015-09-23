module IssuesHelper
  def issue_date_column(record)
    record.issue_date.strftime '%b %Y'
  end

  def issue_box_sizes_column(record)
    record.issue_box_sizes.collect{|ibs| String(ibs.num_copies)}.join(', ')
  end
end
