Rails.application.configure do
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.serve_static_files = false
  config.assets.compile = false
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.eager_load = true
  config.log_level = :info
end
