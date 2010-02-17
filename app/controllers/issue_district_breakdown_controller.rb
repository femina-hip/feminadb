class IssueDistrictBreakdownController < ApplicationController
  before_filter :get_publication

  def index
    @data = IssueDistrictBreakdown.new(@publication).data
  end

  def orders
    @issue = Issue.find(params[:issue_id])
    @region = Region.find(params[:region_id])
    @district = params[:district]

    @orders = Order.find(
      :all,
      :conditions => {
        :region_id => @region.id,
        :district => @district,
        :issue_id => @issue.id
      },
      :order => 'num_copies DESC'
    )
  end

  private
    def get_publication
      @publication = Publication.find(params[:publication_id])
    end
end
