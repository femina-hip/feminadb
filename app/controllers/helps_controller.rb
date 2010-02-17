class HelpsController < ApplicationController
  def index
    render :action => (params[:doc].to_s || 'index')
  end
end
