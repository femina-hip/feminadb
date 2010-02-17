class BulkOrderMailer < ActionMailer::Base

  def exception(recipients, exception)
    recipients recipients
    subject 'ERROR in Bulk Order Creation'
    from 'db@feminahip.or.tz'

    body :exception => exception,
         :main_url => customers_url
  end
end
