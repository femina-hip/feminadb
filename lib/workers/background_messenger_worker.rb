# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class BackgroundMessengerWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    begin
      attempt = 0
      begin
        logger.info "BackgroundMessenger sending #{args.first}..."
        Messenger.new.send *args
        logger.info "sent."
      rescue Exception => e
        if attempt < 3
          logger.info "failed; retrying #{args.first}..."
          attempt += 1
          retry
        else
          logger.info "giving up. Backtrace:"
          logger.info "--------------------"
          logger.info e.backtrace.inspect
          logger.info "--------------------"
        end
      end
    ensure
      self.delete
    end
  end

end
BackgroundMessengerWorker.register
