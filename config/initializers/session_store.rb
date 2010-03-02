# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_feminadb_session',
  :secret => '92ba21b35fb78673b7207957cbf83236e77388b2a460bbce935e3ea86baa0fdaffcbc8ef4d92f8c7da805f202e6a717b0e32dce119f50a6a050265b8cd94e9cf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
