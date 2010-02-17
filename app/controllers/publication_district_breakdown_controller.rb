class PublicationDistrictBreakdownController < ApplicationController
  def index
    @data = PublicationDistrictBreakdown.new.data
    @publications = Publication.find(:all, :order => :name)
  end
end
