class Report::IssuesPerDistrict < Report::Base
  def initialize(start_issue, end_issue)
    @start_issue = start_issue
    @end_issue = end_issue
  end

  def data
    @data ||= begin
      regions_by_id = {}
      Region.all.each { |r| regions_by_id[r.id] = r }

      lines = []

      Order.find_by_sql("
        SELECT region_id, district, SUM(num_copies) AS num_copies
        FROM orders
        WHERE issue_id IN (#{issues.collect(&:id).join(',')})
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
    if @start_issue.publication == @end_issue.publication
      if @start_issue == @end_issue
        "For #{@start_issue.full_name}"
      else
        "For #{@start_issue.publication.name}, starting at \"#{@start_issue.number_and_name}\" and ending at \"#{@end_issue.number_and_name}\""
      end
    else
      "For all publications, starting at \"#{@start_issue.full_name}\" and ending at \"#{@end_issue.full_name}\""
    end
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

  def map_hints
    { :cull_max => 3 } # Dar es Salaam gets SO many issues
  end

  private

  def issues
    @issues ||= if @start_issue.publication == @end_issue.publication
      if @start_issue == @end_issue
        [@start_issue]
      else
        d1 = @start_issue.issue_date
        d2 = @end_issue.issue_date
        d1, d2 = d2, d1 if d1 > d2
        @start_issue.publication.issues.where('issue_date >= ? AND issue_date <= ?', d1, d2)
      end
    else
      d1 = @start_issue.issue_date
      d2 = @end_issue.issue_date
      d1, d2 = d2, d1 if d1 > d2
      Issue.active.where('issue_date >= ? AND issue_date <= ?', d1, d2)
    end
  end

  class << self
    def title
      'Issues per District'
    end

    def description
      [
        'Displays the total number of copies of the given Issues sent to each District'
      ]
    end

    def parameters
      [
        { :key => 'start_issue_id', :title => 'First Issue', :class => Issue },
        { :key => 'end_issue_id', :title => 'Last Issue', :class => Issue }
      ]
    end
  end
end
