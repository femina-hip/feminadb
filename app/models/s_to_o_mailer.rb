class SToOMailer < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper
  helper ActionView::Helpers::TextHelper

  default :from => 'db@feminahip.or.tz'

  def report(recipients, issue, worker_log)
    @issue = issue
    @log = worker_log
    @packing_instructions_url = show_packing_instructions_issue_url(issue)
    @distribution_quote_request_url = show_distribution_quote_request_issue_url(issue)
    @distribution_list_url = show_distribution_list_issue_url(issue)
    @main_url = customers_url

    mail(:to => recipients, :subject => 'Standing Order -> Order report')
  end

  def exception(recipients, exception)
    @exception = exception
    @main_url = customers_url

    mail(:to => recipients, :subject => 'ERROR in Standing Order -> Order')
  end
end
