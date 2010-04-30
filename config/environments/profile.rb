Feminadb::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  Rails.backtrace_cleaner.remove_silencers!
end
