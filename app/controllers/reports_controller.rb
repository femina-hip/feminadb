class ReportsController < ApplicationController
  def index
  end

  def show
    report_class = Report.const_get(params[:id].classify)

    args = report_class.parameters.collect do |parameter|
      if parameter[:class].ancestors.include? ActiveRecord::Base
        begin
          parameter[:class].find params[:report][parameter[:class].name.foreign_key]
        rescue ActiveRecord::RecordNotFound
          flash[:notice] = 'Invalid parameters. Please try again.'
          redirect_to :action => :index
          return
        end
      elsif parameter[:class] == String
        params[parameter[:class].name.underscore]
      else
        raise NotImplementedError
      end
    end

    @report = report_class.new *args
    render :action => 'show_report'
  end

#  def issues_per_region
#    @issue = Issue.find(params[:issue_id])
#    @report = Report::IssuesPerRegion.new(@issue)
#    render :action => 'show_report'
#  end
#
#  def issues_per_person_per_region
#    @issue = Issue.find(params[:issue_id])
#    @report = Report::IssuesPerPersonPerRegion.new(@issue)
#    render :action => 'show_report'
#  end
end
