class Issue < ActiveRecord::Base
  extend DateField

  class DoesNotFitInBoxesException < Exception; end

  include SoftDeletable
  versioned
  acts_as_reportable

  belongs_to :publication
  has_many :issue_box_sizes,
           :order => :num_copies,
           :dependent => :destroy,
           :conditions => 'issue_box_sizes.deleted_at IS NULL'
  has_many :orders,
           :dependent => :destroy,
           :include => [ :region, :delivery_method ],
           :order => 'regions.name, orders.district, orders.customer_name',
           :conditions => 'orders.deleted_at IS NULL'
  has_many :notes,
           :class_name => 'IssueNote',
           :dependent => :destroy,
           :order => 'created_at',
           :conditions => 'issue_notes.deleted_at IS NULL'
  has_many :bulk_order_creators,
           :dependent => :destroy,
           :conditions => 'bulk_order_creators.deleted_at IS NULL'

  validates_presence_of :publication_id
  validates_presence_of :name
  validates_presence_of :issue_date
  validates_presence_of :issue_number
  validates_uniqueness_of :name, :scope => [ :publication_id, :deleted_at ],
                          :case_sensitive => false, :unless => lambda { |issue| issue.deleted_at }
  validates_uniqueness_of :issue_number, :scope => [ :publication_id, :deleted_at ],
                          :case_sensitive => false, :unless => lambda { |issue| issue.deleted_at }
  validates_format_of :issue_number,
                      :with => /\A[-\.A-Za-z0-9]+\Z$/,
                      :message => 'must only contain numbers, letters, periods, and dashes'
  validate :validate_issue_box_sizes_string

  date_field :issue_date

  scope :recent, :conditions => { :deleted_at => nil }, :order => 'issues.issue_date DESC', :limit => 3

  # Returns "Publication 2.3: name"
  def full_name
    "#{publication.name} #{issue_number}: #{name}"
  end

  def number_and_name
    "#{issue_number}: #{name}"
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
    @issue_box_sizes_string_invalid = !(val =~ /^(|\d+(,\s*(\d+)\s*)*)$/)
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

  class PackingInstructionsData < Struct.new(:warehouses, :districts_with_ones)
  end

  def packing_instructions_data
    wh_region_district_ibs = {}

    orders.includes(:delivery_method, :region).each do |order|
      wh = order.delivery_method.warehouse
      region = order.region
      district = order.district

      wh_region_district_ibs[wh] ||= {}
      wh_region_district_ibs[wh][region] ||= {}
      wh_region_district_ibs[wh][region][district] ||= Hash.new(0)
      issue_box_size_quantities(order.num_copies).each do |ibs, num|
        wh_region_district_ibs[wh][region][district][ibs] += num
      end
    end

    warehouses = {}
    ones = issue_box_sizes.collect(&:num_copies).select{|n| n == 1}.first
    districts_with_ones = {}

    wh_region_district_ibs.each do |wh, regions|
      regions.each do |region, districts|
        districts.each do |district, ibss|
          issue_box_size_quantities(ibss[ones]).each do |ibs, num|
            if ibs == ones
              districts_with_ones[wh] ||= []
              districts_with_ones[wh] << [ region, district, num ]
            else
              ibss[ones] -= num * ibs
              ibss[ibs] += num
            end
          end
          ibss.each do |ibs, num|
            warehouses[wh] ||= Hash.new(0)
            warehouses[wh][ibs] += num
          end
        end
      end
    end

    PackingInstructionsData.new(warehouses, districts_with_ones)
  rescue DoesNotFitInBoxesException
    return nil
  end

  # Returns an array of
  # [
  #   {
  #     :region_name => (string),
  #     :num_recipients => (int),
  #     :num_copies => (int)
  #   },
  #   ...
  # ]
  def distribution_quote_request_data
    rows = Order.find_by_sql [
      "SELECT regions.name AS region_name,
              COUNT(*) AS num_recipients,
              SUM(orders.num_copies) AS num_copies
       FROM orders
       INNER JOIN regions
               ON orders.region_id = regions.id
       INNER JOIN delivery_methods
               ON orders.delivery_method_id = delivery_methods.id
              AND delivery_methods.include_in_distribution_quote_request
       WHERE orders.issue_id = ?
         AND orders.deleted_at IS NULL
       GROUP BY regions.id
       ORDER BY regions.name
      ", id ]
    rows.collect do |row|
      {
        :region_name => row['region_name'].to_s,
        :num_recipients => row['num_recipients'].to_i,
        :num_copies => row['num_copies'].to_i
      }
    end
  end

  # Returns a dictionary of
  # DeliveryMethod => [
  #   {
  #     :region_name => (string),
  #     :num_recipients => (int),
  #     :num_copies => (int)
  #   },
  #   ...
  # ]
  def distribution_order_data
    rows = Order.find_by_sql [
        "SELECT orders.delivery_method_id,
                regions.name AS region_name,
                COUNT(*) AS num_recipients,
                SUM(orders.num_copies) AS num_copies
         FROM orders
         INNER JOIN regions
                 ON orders.region_id = regions.id
         WHERE orders.issue_id = ?
           AND orders.deleted_at IS NULL
         GROUP BY orders.delivery_method_id, regions.id
         ORDER BY orders.delivery_method_id, region_name
         ", id ]

    ret = {}

    rows.each do |row|
      delivery_method = DeliveryMethod.find(row[:delivery_method_id].to_i)

      ret[delivery_method] ||= []
      ret[delivery_method] << {
        :region_name => row[:region_name].to_s,
        :num_recipients => row[:num_recipients].to_i,
        :num_copies => row[:num_copies].to_i
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

      orders = Order.active.where(conditions).includes(:customer, :region, :delivery_method, :issue).order('delivery_methods.name, regions.name, orders.district, customers.route, orders.deliver_via, orders.customer_name')
      Order.send(:preload_associations, orders.collect(&:issue), :issue_box_sizes)

      orders.each do |order|
        @delivery_methods[order.delivery_method] ||= DistributionListSubData.new
        @delivery_methods[order.delivery_method].feed(order)
      end
    end

    def each(&block)
      keys = @delivery_methods.keys
      keys.sort!{ |dm1, dm2| dm1.name <=> dm2.name }
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
        keys = @regions.keys
        keys.sort!{ |r1, r2| r1.name <=> r2.name }
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

  # Returns the number of Copies in a particular Warehouse
  def num_copies_in_warehouse(warehouse)
    @num_copies_in_warehouse ||= {}
    @num_copies_in_warehouse[warehouse.id] ||= issue_box_sizes.inject(0) do |s, ibs|
      wibs = ibs.warehouse_issue_box_sizes.select{|wibs| wibs.warehouse_id = warehouse.id}.first
      s += wibs && wibs.num_copies || 0
    end
  end

  # Returns the number of Copies in all Warehouses
  def num_copies_in_all_warehouses
    @num_copies_in_all_warehouses ||= issue_box_sizes.inject(0) do |s1, ibs|
      s1 += ibs.warehouse_issue_box_sizes.inject(0) do |s2, wibs|
        s2 += wibs.warehouse.tracks_inventory ? wibs.num_copies : 0
      end
    end
  end

  # Returns the number of Copies in-house and in all Warehouses
  def num_copies_in_stock
    num_copies_in_house + num_copies_in_all_warehouses
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

  def issue_box_sizes_reversed
    @issue_box_sizes_reversed ||= issue_box_sizes.reverse
  end

  def issue_box_sizes_reversed_i
    @issue_box_sizes_reversed_i ||= issue_box_sizes_reversed.collect{|ibs| ibs.num_copies}
  end

  def issue_box_sizes_reversed_i_without_1
    issue_box_sizes_reversed_i.last == 1 ? issue_box_sizes_reversed_i[0..-2] : issue_box_sizes_reversed_i
  end

  # Returns a hash of { # copies => # boxes }
  def find_box_sizes(num_copies)
    @find_box_sizes_cache ||= {}
    return @find_box_sizes_cache[num_copies] if @find_box_sizes_cache.include? num_copies

    # Try to shortcut: if it divides evenly, use it
    issue_box_sizes_reversed_i.each do |ibs_num_copies|
      next if ibs_num_copies == 1
      i, r = num_copies.divmod(ibs_num_copies)
      return @find_box_sizes_cache[num_copies] = Hash.new(0).merge(ibs_num_copies => i) if r == 0
    end

    ans = find_box_sizes_helper(num_copies)
    @find_box_sizes_cache[num_copies] = if ans.nil?
      nil
    else
      ans.last.default = 0
      ans.last
    end
  end

  # Returns nil or a pair of (# copies remaining, { # copies => # boxes })
  def find_box_sizes_helper(num_copies, remaining_sizes = issue_box_sizes_reversed_i_without_1)
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
