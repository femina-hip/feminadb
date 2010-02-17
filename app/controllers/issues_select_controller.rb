class IssuesSelectController < ApplicationController
  record_select(
    :per_page => 5,
    :search_on => [ 'issues.issue_number', 'issues.name', 'publications.name' ],
    :order_by => 'publications.name, issues.issue_number DESC',
    :full_text_search => true,
    :model => Issue,
    :label => 'record.html.haml'
  )

  protected
    def record_select_includes
      [ :publication ]
    end
end
