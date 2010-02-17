class SToOMailer < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper
  helper ActionView::Helpers::TextHelper

  def report(recipients, issue, worker_log)
    recipients recipients
    subject 'Standing Order -> Order Report'
    from 'db@feminahip.or.tz'

    body :issue => issue, :log => worker_log,
         :packing_instructions_url => show_packing_instructions_publication_issue_url(issue.publication, issue),
         :distribution_quote_request_url => show_distribution_quote_request_publication_issue_url(issue.publication, issue),
         :distribution_list_url => show_distribution_list_publication_issue_url(issue.publication, issue),
         :main_url => customers_url
  end

  def exception(recipients, exception)
    recipients recipients
    subject 'ERROR in Standing Order -> Order'
    from 'db@feminahip.or.tz'

    body :exception => exception,
         :main_url => customers_url
  end
end
