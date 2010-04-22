class Report::IssuesPerDistrict < Report::Base
  def initialize(issue)
    @issue = issue
  end

  def data
    @data ||= begin
      regions_by_id = {}
      Region.all.each { |r| regions_by_id[r.id] = r }

      lines = []

      Order.find_by_sql("
        SELECT region_id, district, SUM(num_copies) AS num_copies
        FROM orders
        WHERE issue_id = #{@issue.id}
          AND deleted_at IS NULL
        GROUP BY region_id, district
        ORDER BY num_copies DESC
      ").each do |row|
        lines << [ regions_by_id[row.region_id.to_i], row.district, row.num_copies.to_i ]
      end

      lines
    end
  end

  def subtitle
    "For #{@issue.full_name}"
  end

  def columns
    [
      { :key => :region, :title => 'Region', :class => Region },
      { :key => :district, :title => 'District', :class => String },
      { :key => :num_copies, :title => 'Qty', :class => Integer }
    ]
  end

  def show_map?
    true
  end

  class << self
    def title
      'Issues per District'
    end

    def description
      [
        'Displays the number of copies of the given Issue sent to each District'
      ]
    end

    def parameters
      [
        { :key => 'issue_id', :title => 'Issue', :class => Issue },
      ]
    end
  end
end
