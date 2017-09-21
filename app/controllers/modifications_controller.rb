class ModificationsController < ApplicationController
  def index
    @search = query_params
    @audits = Audit.search do
      with(:record_id, query_params[:record_id]) if !query_params[:record_id].blank?
      with(:table_name, query_params[:table_name]) if !query_params[:table_name].blank?
      fulltext(query_params[:q]) if query_params[:q]
      order_by(:created_at, :desc)
      paginate(page: page, per_page: per_page)
    end.results

    puts @audits.inspect
  end

  private

  def query_params
    params.permit(:table_name, :record_id, :q)
  end

  def page
    params[:page] || 1
  end

  def per_page
    50
  end
end
