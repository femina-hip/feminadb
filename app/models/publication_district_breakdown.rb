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
      ret = Publication.not_pr_material
      if start_date
        ret = ret.where(['EXISTS (SELECT 1 FROM issues WHERE publication_id = publications.id && issue_date >= ?)', start_date])
      end
    end
  end

  def data
    @data ||= begin
      where_sql = @start_date && "WHERE issue_date >= '#{@start_date.to_formatted_s(:db)}'" || ''

      rows = Order.connection.select_rows("""
        SELECT
          orders.region,
          orders.district,
          publications.name,
          SUM(orders.num_copies)
        FROM orders
        INNER JOIN issues ON orders.issue_id = issues.id
        INNER JOIN publications on issues.publication_id = publications.id
        #{where_sql}
        GROUP BY orders.region, orders.district, publications.name
        ORDER BY orders.region, orders.district
      """)

      ret = []

      rows.each do |region, district, publication_name, num_copies|
        key = [ region, district ].collect{|s| s.to_s.upcase.strip}
        if not ret.last or ret.last[0..1].collect{|s| s.to_s.upcase.strip} != key
          ret << [ region, district, {} ]
        end
        ret.last[2][publication_name] = num_copies.to_i
      end

      ret
    end
  end
end
