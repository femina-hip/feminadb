class BulkOrderCreator
  include ActiveModel::Model
  attr_accessor(:issue_id, :from_issue_id, :from_publication_id, :delivery_method_id, :created_by_email, :order_date, :num_copies, :constant_num_copies, :comment, :search_string)

  # Pretend we're an ActiveRecord::Base, so we can audit this
  cattr_accessor(:table_name)
  @@table_name = 'bulk_orders'
  def attributes
    {
      issue_id: issue_id,
      from_issue_id: from_issue_id,
      from_publication_id: from_publication_id,
      delivery_method_id: delivery_method_id,
      created_by_email: created_by_email,
      order_date: order_date,
      num_copies: num_copies,
      constant_num_copies: constant_num_copies,
      comment: comment,
      search_string: search_string,
    }
  end

  validates_presence_of(:issue_id)
  validates_presence_of(:created_by_email)
  validates(:num_copies, numericality: { only_integer: true, greater_than: 0 }, if: lambda { |boc| boc.constant_num_copies })

  def initialize(options = {})
    super(options)
    self.constant_num_copies = true if creation_type == :customers

    # Coerce "false" to false
    self.constant_num_copies = (constant_num_copies.to_s == 'true')
  end

  def issue
    @issue ||= Issue.find(issue_id)
  end

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

  def n_customers
    case creation_type
    when :publication then do_n_customers_from_publication
    when :issue then do_n_customers_from_issue
    when :customers then do_n_customers_from_customers
    end
  end

  private

  def allowed_customer_ids
    query = search_string
    lots = 999999

    ret = Customer.search_ids do
      if query
        ::QueryBuilder::apply_string_to_search(query, self.instance_variable_get(:@search))
      end
      paginate(page: 1, per_page: lots)
    end
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
        council,
        customer_name,
        delivery_method,
        delivery_address,
        delivery_contact,
        primary_contact_sms_numbers,
        headmaster_sms_numbers
      )
      SELECT
        customers.id,
        #{issue_id},
        standing_orders.id,
        #{num_copies_sql},
        #{comment_sql},
        #{order_date_sql},
        regions.name,
        customers.council,
        customers.name,
        delivery_methods.name,
        customers.delivery_address,
        customers.delivery_contact,
        customers.primary_contact_sms_numbers,
        customers.headmaster_sms_numbers
      FROM standing_orders
      INNER JOIN customers ON standing_orders.customer_id = customers.id
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON regions.delivery_method_id = delivery_methods.id
      WHERE customers.id IN (#{allowed_customer_ids.join(',')})
                        AND standing_orders.publication_id = #{from_publication_id}
    """)
  end

  def do_copy_from_issue
    num_copies_sql = if constant_num_copies
      num_copies
    else
      'orders.num_copies'
    end

    delivery_method_sql = if delivery_method_id.to_i != 0
      "(SELECT name FROM delivery_methods WHERE id = #{delivery_method_id.to_i})"
    else
      'delivery_methods.name'
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
        council,
        customer_name,
        delivery_method,
        delivery_address,
        delivery_contact,
        primary_contact_sms_numbers,
        headmaster_sms_numbers
      )
      SELECT
        orders.customer_id,
        #{issue_id},
        #{num_copies_sql},
        #{comment_sql},
        #{order_date_sql},
        regions.name,
        customers.council,
        customers.name,
        #{delivery_method_sql},
        customers.delivery_address,
        customers.delivery_contact,
        customers.primary_contact_sms_numbers,
        customers.headmaster_sms_numbers
      FROM orders
      INNER JOIN customers ON orders.customer_id = customers.id
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON customers.delivery_method_id = delivery_methods.id
      WHERE orders.issue_id = #{from_issue_id}
        AND orders.customer_id IN (#{allowed_customer_ids.join(',')})
    """)
  end

  def do_n_customers_from_issue
    connection.select_value("""
      SELECT COUNT(DISTINCT orders.customer_id)
      FROM orders
      INNER JOIN customers ON orders.customer_id = customers.id
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON customers.delivery_method_id = delivery_methods.id
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
        council,
        customer_name,
        delivery_method,
        delivery_address,
        delivery_contact,
        primary_contact_sms_numbers,
        headmaster_sms_numbers
      )
      SELECT
        customers.id,
        #{issue_id},
        #{num_copies},
        #{comment_sql},
        #{order_date_sql},
        regions.name,
        customers.council,
        customers.name,
        delivery_methods.name,
        customers.delivery_address,
        customers.delivery_contact,
        customers.primary_contact_sms_numbers,
        customers.headmaster_sms_numbers
      FROM customers
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON regions.delivery_method_id = delivery_methods.id
      WHERE customers.id IN (#{allowed_customer_ids.join(',')})
    """)
  end

  def do_n_customers_from_customers
    connection.select_value("""
      SELECT COUNT(*)
      FROM customers
      INNER JOIN regions ON customers.region_id = regions.id
      INNER JOIN delivery_methods ON regions.delivery_method_id = delivery_methods.id
      WHERE customers.id IN (#{allowed_customer_ids.join(',')})
    """)
  end

  def connection
    Order.connection
  end
end
