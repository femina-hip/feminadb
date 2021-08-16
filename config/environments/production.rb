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

  # [2021-08-16, adamhooper] we're still on the Rails 4 way of doing things,
  # reading SECRET_KEY_BASE env variable
  config.require_master_key = false
  config.read_encrypted_secrets = false
end
