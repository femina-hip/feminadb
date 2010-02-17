class Report::IssuesPerPersonPerRegion < Report::Base
  def initialize(issue)
    @issue = issue
  end

  def data
    Report::IssuesPerRegion.new(@issue).data.collect do |region, num_copies|
      if region.population.to_f != 0.0
        [ region, 100.0 * num_copies / region.population, num_copies, region.population ]
      else
        [ region, 0.0, 0.0 ]
      end
    end.sort{|a,b| b[1] <=> a[1]}
  end

  def subtitle
    "For #{@issue.publication.name} ##{@issue.issue_number}: #{@issue.name}"
  end

  def columns
    [
      { :key => :region, :title => 'Region', :class => Region },
      { :key => :percentage, :title => 'Percentage', :class => Float },
      { :key => :num_copies, :title => 'Qty', :class => Integer },
      { :key => :population, :title => 'Population', :class => Integer }
    ]
  end

  class << self
    def title
      'Issues per Person per Region'
    end

    def description
      [
        'Displays the number of copies of the given Issue sent to each Region divided by the number of people in that Region: a percentage.',
        '100% means everybody in the Region receives 1 copy.'
      ]
    end

    def parameters
      [
        { :key => 'issue_id', :title => 'Issue', :class => Issue },
      ]
    end
  end
end
