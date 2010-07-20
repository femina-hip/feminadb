class ModificationsController < ApplicationController
  def index
    records = VestalVersions::Version.order('updated_at DESC')
    records = records.where(:versioned_type => params[:versioned_type]) if params[:versioned_type]
    records = records.where(:versioned_id => params[:versioned_id]) if params[:versioned_id]
    @versions = records.paginate(:page => page, :per_page => per_page)
    VestalVersions::Version.send(:preload_associations, @versions, [:versioned, :user])
  end

  private

  def page
    params[:page] || 1
  end

  def per_page
    50
  end
end
