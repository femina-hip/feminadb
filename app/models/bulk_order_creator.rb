class BulkOrderCreator
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend DateField

  ATTRS = [ :issue_id, :q, :from_issue_id, :from_publication_id, :num_copies, :delivery_method_id, :comments, :recipients, :enable_num_copies, :order_date, :updated_by ]
  ATTRS.each{ |attr| attr_accessor(attr) }

  date_field(:order_date)

  validate(:has_num_copies)
  validates_presence_of(:issue_id)

  def initialize(options = {})
    options = options.with_indifferent_access
    ATTRS.each do |attr|
      self.send("#{attr}=", options.delete(attr))
    end
    @issue_id = issue_id.to_i
    @from_issue_id = from_issue_id.to_i
    @from_publication_id = from_publication_id.to_i
    @q ||= ''
    @comments = comments.to_s.strip
    @updated_by = @updated_by.id if @updated_by # So we don't serialize a User
    @enable_num_copies = enable_num_copies == 'true' || creation_type == :customers

    if enable_num_copies
      @num_copies = num_copies.to_i
    else
      @num_copies = nil
    end
  end

  def persisted?
    false
  end

  def creation_type
    if from_publication_id > 0
      :publication
    elsif from_issue_id > 0
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

  def customers
    @customers ||= case creation_type
      when :publication then find_standing_orders_from_publication_id.collect(&:customer)
      when :issue then find_orders_from_issue_id.collect(&:customer)
      when :customers then find_customers
    end
  end

  def issue
    @issue ||= Issue.find(issue_id)
  end

  def updated_by
    if @updated_by && !(User === @updated_by)
      @updated_by = User.find(@updated_by)
    end
    @updated_by
  end

  private

  def find_standing_orders_from_publication_id
    query = q
    ids = Customer.search_ids do
      lots = 999999
      CustomersSearcher.apply_query_string_to_search(self, query)
      paginate(:page => 1, :per_page => lots)
    end
    StandingOrder.active.where(:publication_id => from_publication_id, :customer_id => ids).includes(:customer).all
  end

  def find_orders_from_issue_id
    query = q
    ids = Customer.search_ids do
      lots = 999999
      CustomersSearcher.apply_query_string_to_search(self, query)
      paginate(:page => 1, :per_page => lots)
    end
    Order.active.where(:issue_id => issue_id, :customer_id => ids).includes(:customer).all
  end

  def find_customers
    query = q
    Customer.search do
      lots = 999999
      CustomersSearcher.apply_query_string_to_search(self, query)
      paginate(:page => 1, :per_page => lots)
    end.results
  end

  def has_num_copies
    if enable_num_copies && num_copies <= 0
      errors[:base] << 'Please enter a number of copies'
    elsif !enable_num_copies && from_issue_id == 0 && from_publication_id == 0
      errors[:base] << 'Please enter a number of copies'
    end
  end

  def do_copy_from_publication
    ret = []

    find_standing_orders_from_publication_id.each do |standing_order|
      ret << create_order!(standing_order.customer, standing_order.num_copies, :standing_order_id => standing_order.id)
    end

    ret
  end

  def do_copy_from_issue
    ret = []

    find_orders_from_issue_id.each do |order|
      ret << create_order!(order.customer, num_copies || o.num_copies)
    end

    ret
  end

  def do_copy_from_customers
    ret = []

    find_customers.each do |customer|
      ret << create_order!(customer, num_copies)
    end

    ret
  end

  def create_order!(customer, num_copies, options = {})
    options[:order_date] = order_date || DateTime.now
    options[:delivery_method_id] = delivery_method_id || customer.delivery_method_id

    Order.create!({
      :customer => customer, # speed things up
      :customer_id => customer.id,
      :issue_id => issue_id,
      :num_copies => num_copies,
      :comments => comments,
      :order_date => order_date,
      :updated_by => updated_by
    }.merge(options))
  end
end
