# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Feminadb::Application.initialize!

Feminadb::Application.config.middleware.use(ExceptionNotifier,
  :email_prefix => '[FeminaDB] ',
  :sender_address => 'FeminaDB <adam@adamhooper.com>',
  :exception_recipients => %w{adam@adamhooper.com}
)
