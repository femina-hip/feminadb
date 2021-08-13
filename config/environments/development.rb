Rails.application.configure do
  config.action_controller.perform_caching = false
  config.assets.compress = false
  config.assets.debug = true
  config.cache_classes = false
  config.consider_all_requests_local = true
  config.eager_load = false
  config.whiny_nils = true
end
