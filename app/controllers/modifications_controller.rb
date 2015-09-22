class ModificationsController < ApplicationController
  def index
    @audits = Audit.where(query_params).order(created_at: :desc).paginate(page: page, per_page: per_page)
  end

  private

  def query_params
    params.permit(:table_name, :record_id)
  end

  def page
    params[:page] || 1
  end

  def per_page
    50
  end
end
