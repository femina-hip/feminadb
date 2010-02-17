class IssueDistrictBreakdown
  def initialize(publication)
    @publication = publication
  end

  def data
    issues_by_id = {}
    @publication.issues.each do |issue|
      issues_by_id[issue.id] = issue
    end

    rows = Order.connection.select_rows(
      "SELECT regions.name,
              orders.district,
              issues.id,
              SUM(orders.num_copies)
       FROM orders
       INNER JOIN issues ON orders.issue_id = issues.id
       INNER JOIN regions ON orders.region_id = regions.id
       WHERE orders.deleted_at IS NULL
         AND regions.deleted_at IS NULL
         AND issues.deleted_at IS NULL
         AND issues.publication_id = #{@publication.id}
       GROUP BY regions.name, orders.district, issues.id
       ORDER BY regions.name, orders.district
      "
    )

    ret = []

    rows.each do |region_name, district, issue_id, num_copies|
      key = [ region_name, district ].collect{|s| s.to_s.upcase.strip}
      if not ret.last or ret.last[0..1].collect{|s| s.to_s.upcase.strip} != key
        ret << [ region_name, district, {} ]
      end
      issue = issues_by_id[issue_id.to_i]
      ret.last[2][issue] = num_copies.to_i
    end

    ret
  end
end
