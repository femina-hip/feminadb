Rails.application.configure do
  config.assets.debug = true
  config.cache_classes = true
  config.consider_all_requests_local = true  # helps when looking at an error page
  config.whiny_nils = true
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.eager_load = false
end
