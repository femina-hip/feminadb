class Report::IssuesPerCategory < Report::Base
  def initialize(issue)
    @issue = issue
  end

  def data
    return @data if @data

    sums = Order.sum(
      :num_copies,
      :include => { :customer => :type },
      :group => 'customer_types.category',
      :conditions => [ 'orders.issue_id = ? AND orders.deleted_at IS NULL', @issue.id ]
    )
    total = sums.inject(0){|t,r| t + r[1]}

    d = sums.collect do |c,n|
      [ c || '(deleted)', n, 100.0 * n / total ]
    end
    @data = d.sort{|a,b| b[1] <=> a[1]}
  end

  def subtitle
    "For #{@issue.full_name}"
  end

  def columns
    [
      { :key => :category, :title => 'Category', :class => String },
      { :key => :num_copies, :title => 'Copies', :class => Integer },
      { :key => :percentage, :title => 'Percentage', :class => Float },
    ]
  end

  class << self
    def title
      'Issues per Customer Category'
    end

    def description
      [
        'Displays the number of copies of the given Issue sent to each Customer Type'
      ]
    end

    def graph_view
      'pie'
    end

    def parameters
      [
        { :key => 'issue_id', :title => 'Issue', :class => Issue },
      ]
    end
  end
end
