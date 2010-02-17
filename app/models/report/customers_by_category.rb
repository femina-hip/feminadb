class Report::CustomersByCategory < Report::Base
  def data
    total = Customer.count
    Customer.count(
      :all,
      :include => :type,
      :group => 'customer_types.category',
      :conditions => [ 'customers.deleted_at IS NULL' ]
    ).collect do |category, n|
      [ category, n, 100.0 * n / total ]
    end.sort{|a,b| b[1] <=> a[1]}
  end

  def columns
    [
      { :key => :category, :title => 'Category', :class => String },
      { :key => :num_customers, :title => 'Customers', :class => Integer },
      { :key => :percentage, :title => 'Percentage', :class => Float },
    ]
  end

  class << self
    def title
      'Customers by Category'
    end

    def graph_view
      'pie'
    end

    def description
      [
        'Displays the number of Customers we have on record, organized by Category.'
      ]
    end
  end
end
