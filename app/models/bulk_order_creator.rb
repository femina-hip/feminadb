class BulkOrderCreator
  class <<self
    include CustomersQueryRewriter

    def do_copy_from_publication(args)
      args.assert_valid_keys(
        :issue_id, :q, :from_publication_id,
        :num_copies, :delivery_method_id, :order_date, :comments
      )

      if not (args[:issue_id] and args[:from_publication_id])
        raise ArgumentError, 'Need :issue_id and :from_publication_id'
      end

      issue_id = args[:issue_id]
      publication_id = args[:from_publication_id]
      q = args[:q] || ''

      ret = []

      Order.transaction do
        find_customers_from_publication_id(publication_id, q).each do |customer|
          num_copies = args[:num_copies].to_i
          if num_copies <= 0
            so = customer.standing_orders.find_by_publication_id(publication_id, :include => :publication)
            if not so
              raise StandardError, "Standing order found but not found!"
            end
            num_copies = so.num_copies
          end

          ret << create_order!(customer, issue_id, num_copies, args)
        end
      end

      ret
    end

    def do_copy_from_issue(args)
      args.assert_valid_keys(
        :issue_id, :q, :from_issue_id,
        :num_copies, :delivery_method_id, :order_date, :comments
      )

      if not (args[:issue_id] and args[:from_issue_id])
        raise ArgumentError, 'Need :issue_id and :from_issue_id'
      end

      from_issue_id = args[:from_issue_id]
      q = args[:q] || ''
      issue_id = args[:issue_id]

      ret = []

      Order.transaction do
        find_customers_from_issue_id(from_issue_id, q).each do |customer|
          num_copies = args[:num_copies].to_i
          if num_copies <= 0
            o = customer.orders.find_by_issue_id(from_issue_id, :include => { :issue => :publication })
            if not o
              raise StandardError, "Order found but not found!"
            end
            num_copies = o.num_copies
          end

          ret << create_order!(customer, issue_id, num_copies, args)
        end
      end

      ret
    end

    def do_copy_from_customers(args)
      args.assert_valid_keys(
        :issue_id, :q,
        :num_copies, :delivery_method_id, :order_date, :comments
      )

      if not (args[:issue_id] and args[:num_copies])
        raise ArgumentError, 'Need :issue_id and :num_copies'
      end

      q = args[:q] || ''
      issue_id = args[:issue_id]

      ret = []

      Order.transaction do
        find_customers(q).each do |customer|
          ret << create_order!(customer, issue_id, args[:num_copies].to_i, args)
        end
      end

      ret
    end

    def find_customers_from_publication_id(publication_id, q)
      Customer.find_by_contents(
        customers_query(q),
        {:per_page => lots},
        :include => [ :standing_orders ],
        :conditions => [ 'standing_orders.publication_id = ?', publication_id ]
      )
    end

    def find_customers_from_issue_id(issue_id, q)
      Customer.find_by_contents(
        customers_query(q),
        {:per_page => lots},
        :include => [ :orders ],
        :conditions => [ 'orders.issue_id = ?', issue_id ]
      )
    end

    def find_customers(q)
      Customer.find_by_contents(
        customers_query(q),
        {:per_page => lots}
      )
    end

    def create_order!(customer, issue_id, num_copies, options = {})
      order_date = options[:order_date] || DateTime.now
      delivery_method_id = options[:delivery_method_id] || customer.delivery_method_id

      Order.create!(
        :customer_id => customer.id,
        :region_id => customer.region_id,
        :district => customer.district,
        :customer_name => customer.name,
        :deliver_via => customer.deliver_via,
        :delivery_method_id => customer.delivery_method_id,
        :contact_name => customer.contact_name,
        :contact_details => customer.contact_details_string,
        :issue_id => issue_id,
        :num_copies => num_copies,
        :comments => options[:comments],
        :order_date => order_date
      )
    end

    private
      def lots
        9999999
      end
  end
end
