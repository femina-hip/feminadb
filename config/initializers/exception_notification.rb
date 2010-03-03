Feminadb::Application.config.middleware.use(ExceptionNotifier,
  :email_prefix => '[feminadb] ',
  :sender_address => 'FeminaDB <adam@adamhooper.com>',
  :exception_recipients => %w{adam@adamhooper.com}
)
