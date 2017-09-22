source 'https://rubygems.org'

# We output xlsx spreadsheets instead of CSV, because Excel treats CSV cells
# like "+255123123123" as numberic.
# https://github.com/randym/axlsx/issues/234
gem 'rubyzip', '>= 1.2.1' # axlsx dep
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: '776037c0fc799bb09da8c9ea47980bd3bf296874'

gem 'comma'
gem 'dynamic_form'
gem 'font-awesome-rails'
gem 'haml'
gem 'jwt'
gem 'mysql2', '~> 0.3.0'
gem 'passenger' # this is how we run it in production
gem 'progress_bar' # for rake sunspot:reindex
gem 'rake'
gem 'ruby-immutable-struct'
gem 'RedCloth'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'telerivet'
gem 'treetop'
gem 'will_paginate'

gem 'rails', '~> 5.1.4'
gem 'jquery-rails'
gem 'responders'

gem 'sass-rails'
gem 'uglifier'

group :development do
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
