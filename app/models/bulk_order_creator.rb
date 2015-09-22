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
  before_create(:set_initial_status)

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
    update_attribute(:status, 'Preparing list of Orders to create')

    case creation_type
    when :publication then do_copy_from_publication
    when :issue then do_copy_from_issue
    when :customers then do_copy_from_customers
    end
    soft_delete
  end

  def customers
    @customers ||= case creation_type
      when :publication then find_standing_orders_from_publication.collect(&:customer)
      when :issue then find_orders_from_issue.collect(&:customer)
      when :customers then find_customers
    end
  end

  private

  def allowed_customer_ids
    query = search_string
    lots = 999999

    ret = Customer.search_ids do
      with(:deleted, false)
      if query
        Sunspot::QueryBuilder::apply_string_to_search(query, self.instance_variable_get(:@search))
      end
      paginate(page: 1, per_page: lots)
    end
  end

  def find_standing_orders_from_publication
    from_publication.standing_orders.includes(:customer).where(customer_id: allowed_customer_ids)
  end

  def find_orders_from_issue
    query = search_string
    ids = Customer.search_ids do
      lots = 999999
      CustomersSearcher.apply_query_string_to_search(self, query)
      paginate(page: 1, per_page: lots)
    end
    from_issue.orders.includes(:customer).where(customer_id: allowed_customer_ids)
  end

  def find_customers
    Customer.where(id: allowed_customer_ids)
  end

  def set_constant_num_copies
    write_attribute(:constant_num_copies, true) if creation_type == :customers
  end

  def set_initial_status
    write_attribute(:status, 'Waiting for a program to pay attention')
  end

  def do_copy_from_publication
    standing_orders = find_standing_orders_from_publication

    items = standing_orders.collect{ |so| [so.customer, constant_num_copies && num_copies || so.num_copies, {:standing_order_id => so.id}] }

    create_orders!(items)
  end

  def do_copy_from_issue
    orders = find_orders_from_issue

    items = orders.collect{ |o| [o.customer, constant_num_copies && num_copies || o.num_copies] }

    create_orders!(items)
  end

  def do_copy_from_customers
    create_orders!(find_customers.collect{|c| [c, num_copies]})
  end

  def create_orders!(list)
    @num_to_create = list.length
    @num_created = 0
    update_attribute(:status, "Created #{@num_created}/#{@num_to_create} Orders")

    list.each do |args|
      create_order!(*args)

      @num_created += 1
      if @num_created % 20 == 0
        update_attribute(:status, "Created #{@num_created}/#{@num_to_create} Orders")
      end
    end
  end

  def create_order!(customer, num_copies, options = {})
    Order.create!({
      :customer => customer, # speed things up
      :customer_id => customer.id,
      :issue_id => issue_id,
      :num_copies => num_copies,
      :comments => comment,
      :order_date => order_date || DateTime.now,
      :delivery_method_id => delivery_method_id || customer.delivery_method_id,
      :updated_by => created_by_user
    }.merge(options))
  end
end
