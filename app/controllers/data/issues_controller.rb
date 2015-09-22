class Data::IssuesController < ApplicationController
  def index
    @issues = Issue.includes(:publication).order('issues.issue_date DESC')
  end
end
