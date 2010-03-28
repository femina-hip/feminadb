class ModificationsController < ApplicationController
  def index
    @versions = VestalVersions::Version.order('updated_at DESC').limit(per_page).offset((page - 1) * per_page)
  end

  private

  def page
    params[:page] || 1
  end

  def per_page
    50
  end
end
