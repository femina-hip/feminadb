class Report::CustomersByType < Report::Base
  def data
    total = Customer.count
    Customer.count(
      :all,
      :include => :type,
      :group => :customer_type_id,
      :conditions => [ 'customers.deleted_at IS NULL' ]
    ).collect do |type, n|
      [ CustomerType.find(type), n, 100.0 * n / total ]
    end.sort{|a,b| b[1] <=> a[1]}
  end

  def columns
    [
      { :key => :type, :title => 'Type', :class => CustomerType },
      { :key => :num_customers, :title => 'Customers', :class => Integer },
      { :key => :percentage, :title => 'Percentage', :class => Float },
    ]
  end

  class << self
    def title
      'Customers by Type'
    end
  end
end
