# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if ENV['RAILS_ENV'] == 'profile'
  require 'rack/contrib'
  puts "Profiling enabled. Browse to /whatever/url?profile=wall_time to profile"
  use Rack::Profiler, :printer => :graph_html
end

run Feminadb::Application
