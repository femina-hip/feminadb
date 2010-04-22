class PublicationDistrictBreakdown
  extend DateField

  attr_accessor(:start_date)

  date_field(:start_date)

  def initialize(options = {})
    options.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def publications
    @publications ||= begin
      ret = Publication.active.not_pr_material
      if start_date
        ret = ret.includes(:issues).where('issues.issue_date >= ?', start_date)
      end
    end
  end

  def data
    @data ||= begin
      more_sql = @start_date && "AND issue_date >= '#{@start_date.to_formatted_s(:db)}'" || ''

      rows = Order.connection.select_rows(
        "SELECT regions.name,
                orders.district,
                publications.name,
                SUM(orders.num_copies)
         FROM orders
         INNER JOIN issues ON orders.issue_id = issues.id
         INNER JOIN publications on issues.publication_id = publications.id
         INNER JOIN regions ON orders.region_id = regions.id
         WHERE orders.deleted_at IS NULL
           AND regions.deleted_at IS NULL
           AND issues.deleted_at IS NULL
           AND publications.deleted_at IS NULL
           #{more_sql}
         GROUP BY regions.name, orders.district, publications.name
         ORDER BY regions.name, orders.district
        "
      )

      ret = []

      rows.each do |region_name, district, publication_name, num_copies|
        key = [ region_name, district ].collect{|s| s.to_s.upcase.strip}
        if not ret.last or ret.last[0..1].collect{|s| s.to_s.upcase.strip} != key
          ret << [ region_name, district, {} ]
        end
        ret.last[2][publication_name] = num_copies.to_i
      end

      ret
    end
  end
end
