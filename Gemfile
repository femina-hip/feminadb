source 'https://rubygems.org'

# We output xlsx spreadsheets instead of CSV, because Excel treats CSV cells
# like "+255123123123" as numeric.
gem 'caxlsx'

gem 'comma'
gem 'dynamic_form'
gem 'haml'
gem 'jwt'
gem 'mysql2'
gem 'passenger' # this is how we run it in production
gem 'progress_bar' # for rake sunspot:reindex
gem 'rake'
gem 'ruby-immutable-struct'
gem 'RedCloth'
gem 'sunspot_rails'  # Requires Ruby <3.0 until sunspot_rails v>2.5.0. https://github.com/sunspot/sunspot/pull/1004
gem 'sunspot_solr'
gem 'telerivet'
gem 'treetop'
gem 'will_paginate'

gem 'rails', '~> 6.1.0'
gem 'jquery-rails'
gem 'responders'

group :assets do
  gem 'uglifier'
end

group :assets, :development, :test do
  gem 'sass-rails'
end

group :development do
  gem 'puma'
  gem 'web-console'
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-rails'
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
end
