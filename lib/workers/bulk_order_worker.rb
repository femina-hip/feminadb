class BulkOrderWorker < BackgrounDRb::Worker::RailsBase
  def do_work(args)
    logger.info "Bulk Orders with arguments #{args.inspect}"

    recipients = args.delete :recipients

    begin

      args.assert_valid_keys(
        :issue_id, :q,
        :from_issue_id, :from_publication_id,
        :num_copies, :delivery_method_id, :order_date, :comments
      )

      if args[:from_issue_id]
        logger.info "Copying from past issue"
        BulkOrderCreator.do_copy_from_issue(args)
      elsif args[:from_publication_id]
        logger.info "Copying from past publication"
        BulkOrderCreator.do_copy_from_publication(args)
      else
        logger.info "Copying from customers query"
        BulkOrderCreator.do_copy_from_customers(args)
      end
    rescue StandardError => e
      logger.error "Error! #{e.inspect}"
      BulkOrderMailer.exception(recipients, e).deliver
    ensure
      self.delete
    end
  end
end
BulkOrderWorker.register
