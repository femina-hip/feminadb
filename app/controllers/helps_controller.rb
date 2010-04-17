class HelpsController < ApplicationController
  def show
    render(:action => (params[:doc] || 'index'))
  end
end
