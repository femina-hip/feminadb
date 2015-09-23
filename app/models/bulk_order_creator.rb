class BulkOrderCreator < ActiveRecord::Base
  extend DateField

  date_field(:order_date)

  belongs_to(:issue)
  belongs_to(:from_issue, :class_name => 'Issue')
  belongs_to(:from_publication, :class_name => 'Publication')
  belongs_to(:delivery_method)
  belongs_to(:created_by_user, :class_name => 'User', :foreign_key => :created_by)

  validates_presence_of(:issue_id)
  validates_presence_of(:created_by)
  validates(:num_copies, numericality: { only_integer: true, greater_than: 0 }, if: lambda { |boc| boc.constant_num_copies })
  validates_uniqueness_of(:issue_id)

  before_validation(:set_constant_num_copies)

  def creation_type
    if from_publication
      :publication
    elsif from_issue
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
        region_id,
        district,
        customer_name,
        deliver_via,
        delivery_method_id,
        contact_name,
        contact_details
      )
      SELECT
        customers.id,
        #{issue_id},
        standing_orders.id,
        #{num_copies_sql},
        #{comment_sql},
        #{order_date_sql},
        customers.region_id,
        customers.district,
        customers.name,
        customers.deliver_via,
        customers.delivery_method_id,
        customers.contact_name,
        CONCAT_WS(', ', customers.telephone_1, customers.email_1, customers.telephone_2, customers.email_2, customers.telephone_3, customers.fax)
      FROM standing_orders
      INNER JOIN customers ON standing_orders.customer_id = customers.id
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
        region_id,
        district,
        customer_name,
        deliver_via,
        delivery_method_id,
        contact_name,
        contact_details
      )
      SELECT
        customers.id,
        #{issue_id},
        #{num_copies_sql},
        #{comment_sql},
        #{order_date_sql},
        customers.region_id,
        customers.district,
        customers.name,
        customers.deliver_via,
        customers.delivery_method_id,
        customers.contact_name,
        CONCAT_WS(', ', customers.telephone_1, customers.email_1, customers.telephone_2, customers.email_2, customers.telephone_3, customers.fax)
      FROM orders
      INNER JOIN customers ON orders.customer_id = customers.id
      WHERE orders.issue_id = #{from_issue_id}
        AND customers.id IN (#{allowed_customer_ids.join(',')})
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
        region_id,
        district,
        customer_name,
        deliver_via,
        delivery_method_id,
        contact_name,
        contact_details
      )
      SELECT
        customers.id,
        #{issue_id},
        #{num_copies},
        #{comment_sql},
        #{order_date_sql},
        customers.region_id,
        customers.district,
        customers.name,
        customers.deliver_via,
        customers.delivery_method_id,
        customers.contact_name,
        CONCAT_WS(', ', customers.telephone_1, customers.email_1, customers.telephone_2, customers.email_2, customers.telephone_3, customers.fax)
      FROM customers
      WHERE id IN (#{allowed_customer_ids.join(',')})
    """)
  end

  def connection
    BulkOrderCreator.connection
  end
end
