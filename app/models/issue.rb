class Issue < ActiveRecord::Base
  extend DateField

  class DoesNotFitInBoxesException < Exception; end

  belongs_to(:publication)
  has_many(:issue_box_sizes, -> { order(:num_copies) })
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
  validate :validate_issue_box_sizes_string

  date_field :issue_date

  def recent
    order(issue_date: :desc).limit(3)
  end

  # Returns "Publication 2.3: name"
  def full_name
    "#{publication.name} #{number_and_name}"
  end

  def title; full_name; end

  def number_and_name
    "#{issue_number}: #{name}"
  end

  def full_name_for_issue_select
    "[#{publication.name}] #{number_and_name}"
  end

  # Returns a string list of issue box sizes
  def issue_box_sizes_string(force_reload = false)
    issue_box_sizes(force_reload).collect(&:num_copies).sort.join(', ')
  end

  # Returns [1, 50, 75, 100]
  def issue_box_sizes_i
    @issue_box_sizes_i ||= issue_box_sizes.collect(&:num_copies)
  end

  # Sets the box sizes of the issue
  # The input must be a string like "4, 2, 15"
  def issue_box_sizes_string=(val)
    val.strip!
    @issue_box_sizes_string_invalid = !(val =~ /\A(|\d+(,\s*(\d+)\s*)*)\z/)
    return if @issue_box_sizes_string_invalid

    # FIXME: don't commit IBS changes until save
    transaction do
      new_sizes = val.split(/[,;]/).map{ |s| s.to_i }.select{ |i| i > 0 }.sort.uniq
      # Copy the old one, since we'll be editing the real list
      old_sizes = issue_box_sizes.map{ |ibs| ibs.num_copies.to_i }.sort

      # Merge the new list with the old one (don't build new issue box sizes
      # when not strictly necessary)
      new_i = 0
      old_i = 0

      while new_i < new_sizes.length and old_i < old_sizes.length
        new = new_sizes[new_i]
        old = old_sizes[old_i]

        if new == old
          new_i += 1
          old_i += 1
          next
        end

        if new > old
          ibs = issue_box_sizes.find_by_num_copies(old)
          issue_box_sizes.delete(ibs)
          ibs.destroy
          old_i += 1
          next
        end

        if new < old
          issue_box_sizes.build(:num_copies => new)
          new_i += 1
          next
        end

        raise Exception.new('Broken source code!')
      end

      while new_i < new_sizes.length
        issue_box_sizes.build(:num_copies => new_sizes[new_i])
        new_i += 1
      end

      while old_i < old_sizes.length
        ibs = issue_box_sizes.find_by_num_copies(old_sizes[old_i])
        issue_box_sizes.delete(ibs)
        ibs.destroy
        old_i += 1
      end

      issue_box_sizes_string
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
    rows = Order.find_by_sql ["""
      SELECT
        delivery_method,
        region,
        COUNT(*) AS num_recipients,
        SUM(orders.num_copies) AS num_copies
      FROM orders
      WHERE orders.issue_id = ?
      GROUP BY delivery_method, region
      ORDER BY delivery_method, region
      """, id ]
    last_delivery_method = nil
    ret = []
    rows.each do |row|
      delivery_method = row['delivery_method']
      if delivery_method != last_delivery_method
        last_delivery_method = delivery_method
        ret <<= {
          delivery_method: delivery_method,
          rows: []
        }
      end

      ret.last[:rows] <<= {
        region: row['region'].to_s,
        num_recipients: row['num_recipients'].to_i,
        num_copies: row['num_copies'].to_i
      }
    end
    ret
  end

  # Created by Issue.distribution_list_data
  # This is an enumerable which maps (in order) from DeliveryMethod to
  # DistributionListSubData.
  class DistributionListData
    include Enumerable

    def initialize(issue, delivery_method = nil)
      @delivery_methods = {}

      conditions = { :issue_id => issue.id }
      if delivery_method
        conditions.merge!(:delivery_method_id => delivery_method.id)
      end

      orders = Order
        .where(conditions)
        .includes(:issue => :issue_box_sizes)
        .order(:delivery_method, :region, :district, :customer_name)

      orders.each do |order|
        @delivery_methods[order.delivery_method] ||= DistributionListSubData.new
        @delivery_methods[order.delivery_method].feed(order)
      end
    end

    def each(&block)
      keys = @delivery_methods.keys
      keys.sort!
      keys.collect{|dm| [ dm, @delivery_methods[dm] ]}.each(&block)
    end

    # Created by Issue.distribution_list_data
    # This is an enumerable which maps (in order) from Region to
    # DistributionListSubSubData.
    class DistributionListSubData
      include Enumerable

      attr :regions

      def initialize
        @regions = {}
      end

      # Used during construction
      def feed(order)
        @regions[order.region] ||= DistributionListSubSubData.new
        @regions[order.region].feed(order)
      end

      def each(&block)
        keys = @regions.keys.sort
        keys.collect{ |r| [ r, @regions[r] ]}.each(&block)
      end

      # Calculates the total of :attr in the orders
      def total(attr)
        @total ||= {}
        @total[attr] ||= @regions.values.inject(0) { |sum, v| sum + v.total(attr) }
      end

      # Calculates the total number of boxes of the given size
      def total_boxes(ibs)
        @total_boxes ||= {}
        @total_boxes[ibs] ||= @regions.values.inject(0) { |sum, v| sum + v.total_boxes(ibs) }
      end

      # Created by Issue.distribution_list_data.
      # This is an enumerable which maps (in order) from district name to
      # a list of orders.
      class DistributionListSubSubData
        include Enumerable

        attr :districts

        def initialize
          @districts = {}
        end

        # Used during construction
        def feed(order)
          order.num_boxes # Throw an exception if applicable

          @districts[order.district || ''] ||= []
          @districts[order.district || ''] << order
        end

        def each(&block)
          keys = @districts.keys.sort
          keys.collect{|d| [ d, @districts[d] ]}.each(&block)
        end

        # Calculates the total of :attr in the orders
        def total(attr)
          @total ||= {}
          @total[attr] ||= @districts.values.inject(0) do |sum, orders|
            sum + orders.inject(0) do |sum2, order|
              sum2 + order.send(attr).to_i
            end
          end
        end

        # Calculates the total number of boxes of the given size
        def total_boxes(ibs)
          @districts.values.inject(0) do |sum, orders|
            sum + orders.inject(0) do |sum2, order|
              sum2 + order.num_boxes[ibs].to_i
            end
          end
        end
      end
    end
  end

  # Returns a DistributionListData structure
  def distribution_list_data(delivery_method = nil)
    @distribution_list_data ||= {}
    @distribution_list_data[delivery_method] ||= DistributionListData.new(self, delivery_method)
  end

  # Returns a dictionary of { IssueBoxSize => (int) num_boxes }
  def issue_box_size_quantities(num_copies)
    ret = find_box_sizes(num_copies) || only_box_size_1_hash(num_copies)
    return ret if ret

    # We failed to find a combination of boxes
    raise DoesNotFitInBoxesException.new('Cannot fit issues into any boxes')
  end

  def distribution_list_csv(delivery_method)
    FasterCSV.generate do |csv|
      box_sizes = issue_box_sizes_i.reject{ |n| n == 1 }

      csv << ([ 'ID', 'Region', 'District', 'Final Recipient', 'Delivery Instructions', 'Qty'] + box_sizes.collect{|n| "x#{n}"} + [ 'Delivery Note', 'Date Delivered', 'Delivery Comments' ])

      orders.where(delivery_method: delivery_method).each do |order|
        sizes = issue_box_size_quantities(order.num_copies)

        csv << ([ order.id, order.region, order.district, order.customer_name, order.delivery_address, order.num_copies ] + box_sizes.collect{ |ibs| n = sizes[ibs] || 0; n > 0 && n.to_s || '' })
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

  private

  def validate_issue_box_sizes_string
    # Since issue_box_sizes_string isn't an attribute, this is a bit of
    # a hack. Fixes bug #32.
    if @issue_box_sizes_string_invalid
      errors.add(
        :issue_box_sizes_string,
        'must be of the form "50, 75, 100"'
      )
    end
  end

  # Returns a hash of { # copies => # boxes }
  def find_box_sizes(num_copies)
    @find_box_sizes_cache ||= {}
    cache_key = num_copies
    return @find_box_sizes_cache[cache_key] if @find_box_sizes_cache.include?(cache_key) # might be nil

    size_integers = issue_box_sizes_i.reverse

    # Try to shortcut: if it divides evenly, use it
    size_integers.each do |ibs_num_copies|
      next if ibs_num_copies == 1
      i, r = num_copies.divmod(ibs_num_copies)
      return @find_box_sizes_cache[num_copies] = Hash.new(0).merge(ibs_num_copies => i) if r == 0
    end

    ans = find_box_sizes_helper(num_copies, size_integers.reject{|i| i == 1})
    @find_box_sizes_cache[cache_key] = if ans.nil?
      nil
    else
      ans.last.default = 0
      ans.last
    end
  end

  # Returns nil or a pair of (# copies remaining, { # copies => # boxes })
  def find_box_sizes_helper(num_copies, remaining_sizes)
    return [ num_copies, {} ] if num_copies == 0
    return nil if remaining_sizes.empty?

    ibs_num_copies, other_sizes = remaining_sizes[0], remaining_sizes[1..-1]

    i, r = num_copies.divmod(ibs_num_copies)
    return [ 0, { ibs_num_copies => i } ] if r == 0

    while i > 0 do
      ans = find_box_sizes_helper(r, other_sizes)
      if ans
        ans.last.update({ ibs_num_copies => i })
        return ans
      end

      i -= 1
      r += ibs_num_copies
    end

    return find_box_sizes_helper(num_copies, other_sizes)
  end

  def only_box_size_1_hash(num_copies)
    return nil if @box_size_1_nil
    @box_size_1 ||= issue_box_sizes.find_by_num_copies(1)
    @box_size_1_nil ||= @box_size_1.nil?
    return nil if @box_size_1_nil
    Hash.new(0).merge(1 => num_copies)
  end
end
