class BulkOrderMailer < ActionMailer::Base
  default :from => 'db@feminahip.or.tz'

  def exception(recipients, exception)
    @exception = exception
    @main_url = customers_url

    mail(:to => recipients, :subject => 'ERROR in bulk Order creation')
  end
end
