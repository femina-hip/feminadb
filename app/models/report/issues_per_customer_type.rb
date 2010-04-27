class Report::IssuesPerCustomerType < Report::Base
  attr_reader(:issue)

  def initialize(issue)
    @issue = issue
  end

  def data
    @data ||= begin
      lines = []

      Order.find_by_sql("
        SELECT customer_types.category AS category,
               customer_types.name AS customer_type_name,
               customer_types.description AS description,
               COUNT(customers.id) AS num_customers,
               SUM(orders.num_copies) AS num_copies
        FROM orders
        LEFT JOIN customers ON orders.customer_id = customers.id
                           AND customers.deleted_at IS NULL
        LEFT JOIN customer_types ON customers.customer_type_id = customer_types.id
                                AND customer_types.deleted_at IS NULL
        WHERE orders.deleted_at IS NULL
          AND orders.issue_id = #{issue.id}
        GROUP BY customer_types.name
        ORDER BY customer_types.category, customer_types.name
      ").each do |row|
        lines << [ row.category.to_s, row.customer_type_name.to_s, row.description.to_s, row.num_customers.to_i, row.num_copies.to_i ]
      end

      sum = lines.inject(0) { |s,row| s += row.last }

      lines.each do |line|
        num_copies = line.last
        line << 100.0 * num_copies / sum
      end

      lines
    end
  end

  def subtitle
    "For #{@issue.full_name}"
  end

  def columns
    [
      { :key => :category, :title => 'Customer Category', :class => String },
      { :key => :customer_type_name, :title => 'Customer Type', :class => String },
      { :key => :customer_type_description, :title => 'Description', :class => String },
      { :key => :num_customers, :title => '# Customers', :class => Integer },
      { :key => :num_copies, :title => '# Copies', :class => Integer },
      { :key => :percentage, :title => '% of Copies', :class => Float }
    ]
  end

  class << self
    def title
      'Issues per Customer Type'
    end

    def description
      [
        'Displays the number of copies of the Issue sent to each Customer Type'
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
