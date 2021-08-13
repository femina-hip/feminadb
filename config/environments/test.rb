Rails.application.configure do
  config.cache_classes = true
  config.whiny_nils = true
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection    = false
  config.action_mailer.delivery_method = :test
  config.eager_load = false
end
