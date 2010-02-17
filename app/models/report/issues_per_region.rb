class Report::IssuesPerRegion < Report::Base

  def initialize(issue)
    @issue = issue
  end

  def data
    @data ||= Order.sum(
      :num_copies,
      :group => :region,
      :order => 'SUM(orders.num_copies) DESC',
      :include => :region,
      :conditions => [ 'orders.issue_id = ? AND orders.deleted_at IS NULL', @issue.id ]
    )
  end

  def subtitle
    "For #{@issue.full_name}"
  end

  def columns
    [
      { :key => :region, :title => 'Region', :class => Region },
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
