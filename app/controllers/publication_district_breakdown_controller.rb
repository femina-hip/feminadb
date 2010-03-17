class PublicationDistrictBreakdownController < ApplicationController
  def index
    @data = PublicationDistrictBreakdown.new.data
    @publications = Publication.where(:deleted_at => nil).order(:name).all
  end
end
