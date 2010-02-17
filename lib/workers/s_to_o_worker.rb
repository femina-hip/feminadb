# Should be StandingOrderToOrderWorker, but Backgroundrb hates the filename
class SToOWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    begin
      args.assert_valid_keys :issue_id, :recipients

      issue_id = args[:issue_id]
      issue = Issue.find(issue_id)
      log = { :errors => [], :skipped => [], :created => [], :updated => [] }
  
      logger.info "Generating Orders for Issue #{issue.id}"
      update_progress

      @standing_orders = StandingOrder.find_all_by_publication_id(
        issue.publication_id, :include => { :customer => [ :region ] },
        :order => 'regions.name, customers.district, customers.name')

      StandingOrder.transaction do
        @num_complete = 0
        @standing_orders.each do |standing_order|
          @current_standing_order = standing_order

          existing = Order.find_by_standing_order_id_and_issue_id(standing_order.id, issue.id)
          if existing
            if existing.num_copies == standing_order.num_copies
              log[:skipped] << make_report_line(standing_order)
            else
              begin
                existing.num_copies = standing_order.num_copies
                existing.save!
                log[:updated] << make_report_line(standing_order)
              rescue ActiveRecord::RecordInvalid
                log[:errors] << make_report_line(standing_order)
              end
            end
          else # A new Order must be created
            begin
              standing_order.create_order_for_issue!(issue)
              log[:created] << make_report_line(standing_order)
            rescue ActiveRecord::RecordInvalid
              log[:errors] << make_report_line(standing_order)
            end
          end

          @num_complete += 1
          update_progress
        end
      end
  
      logger.info "Completed: created #{@num_complete} orders"

      SToOMailer.deliver_report(args[:recipients], issue, log)

      logger.info "Sent report mail to #{args[:recipients].to_s}"
  
    rescue StandardError => e
      SToOMailer.deliver_exception(args[:recipients], e)

    ensure
      self.delete
    end
  end

  private
    def update_progress
      num_standing_orders = @standing_orders.nil? ? 0 : @standing_orders.length
  
      results[:num_complete] = @num_complete
      results[:num_standing_orders] = num_standing_orders
      if not @current_standing_order.nil?
        results[:current_standing_order_id] = @current_standing_order.id
      end
    end

    def make_report_line(standing_order)
      {
        :region => standing_order.customer.region,
        :district => standing_order.customer.district,
        :customer_name => standing_order.customer.name,
        :num_copies => standing_order.num_copies
      }
    end

end
SToOWorker.register
