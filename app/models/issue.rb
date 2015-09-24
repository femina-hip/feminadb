class Issue < ActiveRecord::Base
  extend DateField

  belongs_to(:publication)
  has_many(:orders, -> { order(:delivery_method, :region, :district, :customer_name) })
  has_many(:notes, -> { order(:created_at) }, class_name: 'IssueNote')
  has_many(:bulk_order_creators)

  validates_presence_of :publication_id
  validates_presence_of :name
  validates_presence_of :issue_date
  validates_presence_of :issue_number
  validates_uniqueness_of :name, scope: :publication_id, case_sensitive: false
  validates_uniqueness_of :issue_number, scope: :publication_id, case_sensitive: false
  validates_format_of :issue_number,
                      :with => /\A[-\.A-Za-z0-9]+\z/,
                      :message => 'must only contain numbers, letters, periods, and dashes'
  validates_format_of :box_sizes, with: /\A([0-9]+,\s*)*[0-9]+\z/, message: 'must be a list of box sizes like "50, 100"'

  date_field :issue_date

  def recent
    order(issue_date: :desc).limit(3)
  end

  # Returns "Publication 2.3: name"
  def full_name
    "#{publication.name} #{number_and_name}"
  end

  def title
    full_name
  end

  def number_and_name
    "#{issue_number}: #{name}"
  end

  def full_name_for_issue_select
    "[#{publication.name}] #{number_and_name}"
  end

  # Returns [50, 75, 100]
  #
  # This will never include the box size of 1.
  #
  # [adamh] back in 2010, I ascribed some meaning to box size 1: some
  # publications had it and others didn't. I don't remember what the point was,
  # and I'm sure nobody else does, either. Now the UI will *always* allow box
  # size==1, and the distribution manager can handle the case as he/she sees
  # fit. This avoids a clunky exception.
  def box_sizes_i
    @box_sizes_i ||= box_sizes.split(/,\s+/).map(&:to_i).sort.reject { |i| i < 2 }
  end

  # The (Array of Integer) box sizes that actually get *used*.
  #
  # Unlike box_sizes_i, this *may* have box size 1, if issues don't fit into
  # other boxes. It may also *omit* box sizes returned by box_sizes_i, if they
  # are completely unused in all orders.
  def used_box_sizes_i(delivery_method=nil)
    @used_box_sizes_i ||= {}
    @used_box_sizes_i[delivery_method] ||= begin
      some_orders = orders
      some_orders = some_orders.where(delivery_method: delivery_method) if delivery_method
      order_box_sizes(some_orders)
    end
  end

  # Returns an Array of:
  # [
  #   {
  #     delivery_method: 'Some delivery method',
  #     rows: [
  #       {
  #         :region_name => (string),
  #         :num_recipients => (int),
  #         :num_copies => (int)
  #       },
  #       ...
  #     ]
  #   },
  #   ...
  # }
  def distribution_order_data
    rows = Order.connection.execute("""
      SELECT
        delivery_method,
        region,
        COUNT(*) AS num_recipients,
        SUM(orders.num_copies) AS num_copies
      FROM orders
      WHERE orders.issue_id = #{id}
      GROUP BY delivery_method, region
      ORDER BY delivery_method, region
    """)
    last_delivery_method = nil
    ret = []
    rows.each do |row|
      delivery_method = row[0]
      if delivery_method != last_delivery_method
        last_delivery_method = delivery_method
        ret <<= {
          delivery_method: delivery_method,
          rows: []
        }
      end

      ret.last[:rows] <<= {
        region: row[1],
        num_recipients: row[2],
        num_copies: row[3]
      }
    end
    ret
  end

  class LightweightOrder
    def initialize(array)
      @array = array
    end

    def id; @array[0]; end
    def delivery_method; @array[1]; end
    def region; @array[2]; end
    def district; @array[3]; end
    def customer_name; @array[4]; end
    def delivery_address; @array[5]; end
    def num_copies; @array[6]; end
  end

  # Returns an Array of LightweightOrders with just enough info to build a
  # distribution list.
  #
  # This uses raw SQL, because ActiveRecord is too heavy.
  def distribution_list_data(delivery_method = nil)
    @distribution_list_data ||= {}
    @distribution_list_data[delivery_method] ||= begin
      where_sql = delivery_method && " AND delivery_method = #{Order.sanitize_sql(delivery_method)}" || ''

      Order.connection.execute("""
        SELECT
          id,
          delivery_method,
          region,
          district,
          customer_name,
          delivery_address,
          num_copies
        FROM orders
        WHERE issue_id = #{id}
        #{where_sql}
        ORDER BY delivery_method, region, district, customer_name
      """).map { |array| LightweightOrder.new(array) }
    end
  end

  def distribution_list_csv(delivery_method)
    these_orders = orders
    these_orders = these_orders.where(delivery_method: delivery_method) if delivery_method
    these_box_sizes = order_box_sizes(these_orders)

    CSV.generate do |csv|
      csv << ([ 'ID', 'Region', 'District', 'Final Recipient', 'Delivery Instructions', 'Qty'] + these_box_sizes.map{|n| "x#{n}"} + [ 'Delivery Note', 'Date Delivered', 'Delivery Comments' ])

      distribution_list_data.each do |order|
        sizes = find_box_sizes(order.num_copies)

        csv << ([ order.id, order.region, order.district, order.customer_name, order.delivery_address, order.num_copies ] + these_box_sizes.map{ |bs| sizes[bs].to_s })
      end
    end
  end

  def publication_name
    publication && publication.name || '???'
  end

  # An Array of all String delivery methods used by orders for this issue
  def order_delivery_methods
    @order_delivery_methods = orders.select(:delivery_method).distinct.map(&:delivery_method).sort
  end

  # Returns a hash of { # copies => # boxes }
  def find_box_sizes(num_copies)
    @find_box_sizes_cache ||= {}

    @find_box_sizes_cache[num_copies] ||= begin
      ret = {}

      # If box sizes are [50, 75, 100] and we ask for 150 boxes, then return
      # 2*75 over the greedy-algorithm answer of 1*100, 1*50.
      fits_exactly_into_single_box_size = false
      for box_size in box_sizes_i.reverse
        if num_copies / box_size * box_size == num_copies
          fits_exactly_into_single_box_size = true
          ret[box_size] = num_copies / box_size
          break
        end
      end

      if !fits_exactly_into_single_box_size
        num_copies_remaining = num_copies
        for box_size in box_sizes_i.reverse
          num_boxes, num_copies_remaining = num_copies_remaining.divmod(box_size)
          ret[box_size] = num_boxes if num_boxes > 0
        end

        # Sometimes the copies don't all fit into boxes. That's a problem for
        # a human to handle, not us. Put the rest into the fictional "size-1"
        # box so a human can eventually see the problem.
        ret[1] = num_copies_remaining if num_copies_remaining > 0
      end

      ret
    end
  end

  private

  def order_box_sizes(some_orders)
    distinct_num_copies = some_orders.select(:num_copies).distinct.map(&:num_copies)
    distinct_num_copies
      .map { |num_copies| find_box_sizes(num_copies).keys }
      .flatten
      .uniq
      .sort
  end
end
