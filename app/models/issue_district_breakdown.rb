class IssueDistrictBreakdown
  extend DateField

  attr_accessor(:start_date)
  attr_reader(:publication)

  date_field(:start_date)

  def initialize(publication, options = {})
    @publication = publication

    options.each do |k,v|
      self.send("#{k}=", v)
    end
  end

  def issues
    @issues ||= begin
      issues = publication.issues.includes(:publication)
      if start_date
        issues = issues.where('issues.issue_date >= ?', start_date)
      end
    end
  end

  def data
    @data ||= begin
      issues_by_id = {}
      issues.each { |i| issues_by_id[i.id] = i }

      rows = Order.connection.select_rows("""
        SELECT
          region,
          district,
          issue_id,
          SUM(orders.num_copies)
        FROM orders
        WHERE issue_id IN (#{issues.collect(&:id).join(',')})
        GROUP BY region, district, issue_id
        ORDER BY region, district
      """)

      ret = []

      rows.each do |region, district, issue_id, num_copies|
        issue = issues_by_id[issue_id.to_i]

        key = [ region, district ]
        if not ret.last or ret.last[0..1] != key
          ret << [ region, district, {} ]
        end

        ret.last.last[issue] = num_copies.to_i
      end

      ret
    end
  end
end
