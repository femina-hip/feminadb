=begin
A mock of a BackgrounDRb instance running inside the 'test' environment.
Instead of scheduling the task, then executing it asynchronously, we
directly invoke the 'do_work' method of the Worker.

This mock is needed because the actual BackgrounDRb instance, if running, is
probably tied to a different environment than 'test'. Scheduled tasks that
modify database entries will hit the instance's environment database (eg.
'development' instead of the 'test' database), flunking tests in the best
case and corrupting the instance's environment data in the worst case.

To use, simply add the following line in your Rails.root/test_helper.rb:

# inject the mock backgroundrb to the test environment.
require File.dirname(__FILE__) + '/mocks/test/backgroundrb_mock.rb'
=end

module BackgrounDRb
  module Worker
    class RailsBase
      attr :results
      
      def initialize(workers)
        @results = {}
        @workers = workers
      end
      
      def logger
        ActiveRecord::Base.logger # pass through to the Rails logger
      end
      
      def delete
        @workers.delete self.object_id.to_s
      end
      
      def self.register ; end
    end
  end
  
  class MockDRbObject
    def initialize
      @workers = {}
    end
    
    def new_worker(opts={})
      # instanciate the worker of appropriate class and pass args to do_work
      require "workers/#{opts[:class]}"
      worker_class = Inflector.constantize(Inflector.camelize(opts[:class].to_s))
      worker = worker_class.new @workers
      worker_key = worker.object_id.to_s
      @workers[worker_key] = worker
      worker.do_work opts[:args]
      worker_key
    end
    
    def worker(key)
      # backgroundrb 0.2.1 raises NoMethodError when object is not found,
      # probably because when key is not found, nil is returned and not a
      # worker object, and calling nil.object fails later?
      nil.object unless @workers.has_key? key # raises NoMethodError
      @workers[key]
    end
  end
  
  class MiddleManRailsProxy
    def self.init
      MockDRbObject.new
    end
  end
end

# Overridde the MiddleMan from the backgroundrb plugin with our Mock.
if Object.constants.include? 'MiddleMan'
  Object.send :remove_const, 'MiddleMan'
  MiddleMan = BackgrounDRb::MiddleManRailsProxy.init
end
