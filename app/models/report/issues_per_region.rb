class Report::IssuesPerRegion < Report::Base

  def initialize(issue)
    @issue = issue
  end

  def data
    @data ||= Order
      .where(issue_id: @issue.id)
      .group(:region)
      .sum(:num_copies)
      .sort_by { |k, v| -v }
  end

  def subtitle
    "For #{@issue.full_name}"
  end

  def columns
    [
      { :key => :region, :title => 'Region', :class => String },
      { :key => :num_copies, :title => 'Qty', :class => Integer }
    ]
  end

  class << self
    def title
      'Issues per Region'
    end

    def description
      [
        'Displays the number of copies of the given Issue sent to each Region'
      ]
    end

    def parameters
      [
        { :key => 'issue_id', :title => 'Issue', :class => Issue },
      ]
    end
  end
end
