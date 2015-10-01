class BulkOrderCreator
  include ActiveModel::Model
  attr_accessor(:issue_id, :from_issue_id, :from_publication_id, :delivery_method_id, :created_by_email, :order_date, :num_copies, :constant_num_copies)

  extend DateField
  date_field(:order_date)

  validates_presence_of(:issue_id)
  validates_presence_of(:created_by_email)
  validates(:num_copies, numericality: { only_integer: true, greater_than: 0 }, if: lambda { |boc| boc.constant_num_copies })
  validates_uniqueness_of(:issue_id)

  before_validation(:set_constant_num_copies)

  def creation_type
    if from_publication_id
      :publication
    elsif from_issue_id
      :issue
    else
      :customers
    end
  end

  def do_copy
    case creation_type
    when :publication then do_copy_from_publication
    when :issue then do_copy_from_issue
    when :customers then do_copy_from_customers
    end
  end

  private

  def allowed_customer_ids
    query = search_string
    lots = 999999

    ret = Customer.search_ids do
      if query
        Sunspot::QueryBuilder::apply_string_to_search(query, self.instance_variable_get(:@search))
      end
      paginate(page: 1, per_page: lots)
    end
  end

  def set_constant_num_copies
    write_attribute(:constant_num_copies, true) if creation_type == :customers
  end

  def do_copy_from_publication
    num_copies_sql = if constant_num_copies
      num_copies
    else
      'standing_orders.num_copies'
    end

    comment_sql = connection.quote(comment)
    order_date_sql = connection.quote(order_date || DateTime.now)

    connection.execute("""
      INSERT INTO orders (
        customer_id,
        issue_id,
        standing_order_id,
        num_copies,
        comments,
        order_date,
        region,
        district,
        customer_name,
        delivery_method,
        delivery_address,
        delivery_contact
      )
      SELECT
        customers.id,
        #{issue_id},
        standing_orders.id,
        #{num_copies_sql},
        #{comment_sql},
        #{order_date_sql},
        regions.name,
        customers.district,
        customers.name,
        delivery_methods.name,
        customers.delivery_address,
        customers.delivery_contact
      FROM standing_orders
      INNER JOIN customers ON standing_orders.customer_id = customers.id
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON customers.delivery_method_id = delivery_methods.id
      WHERE customers.id IN (#{allowed_customer_ids.join(',')})
    """)
  end

  def do_copy_from_issue
    num_copies_sql = if constant_num_copies
      num_copies
    else
      'standing_orders.num_copies'
    end

    comment_sql = connection.quote(comment)
    order_date_sql = connection.quote(order_date || DateTime.now)

    connection.execute("""
      INSERT INTO orders (
        customer_id,
        issue_id,
        num_copies,
        comments,
        order_date,
        region,
        district,
        customer_name,
        delivery_method,
        delivery_address,
        delivery_contact
      )
      SELECT
        orders.customer_id,
        #{issue_id},
        #{num_copies_sql},
        #{comment_sql},
        #{order_date_sql},
        regions.name,
        customers.district,
        customers.name,
        customers.delivery_address,
        customers.delivery_contact
      FROM orders
      INNER JOIN customers ON orders.customer_id = customers.id
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON customer.delivery_method_id = delivery_methods.id
      WHERE orders.issue_id = #{from_issue_id}
        AND orders.customer_id IN (#{allowed_customer_ids.join(',')})
    """)
  end

  def do_copy_from_customers
    comment_sql = connection.quote(comment)
    order_date_sql = connection.quote(order_date || DateTime.now)

    connection.execute("""
      INSERT INTO orders (
        customer_id,
        issue_id,
        num_copies,
        comments,
        order_date,
        region,
        district,
        customer_name,
        delivery_method,
        delivery_address,
        delivery_contact
      )
      SELECT
        customers.id,
        #{issue_id},
        #{num_copies},
        #{comment_sql},
        #{order_date_sql},
        regions.name,
        customers.district,
        customers.name,
        delivery_methods.name,
        customers.delivery_address,
        customers.delivery_contact
      FROM customers
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON customers.delivery_method_id = delivery_methods.id
      WHERE id IN (#{allowed_customer_ids.join(',')})
    """)
  end

  def connection
    Order.connection
  end
end
