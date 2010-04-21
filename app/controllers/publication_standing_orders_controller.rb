class PublicationStandingOrdersController < ApplicationController
  include CustomerFilterControllerMethods

  require_role 'edit-orders', :except => :index

  before_filter :load_publication

  # GET /publications/1/standing_orders
  # GET /publications/1/standing_orders.csv
  def index
    @standing_orders = @publication.standing_orders.includes(:customer => [:region, :delivery_method, :type]).order('delivery_methods.abbreviation, regions.name, customers.district, customers.name').where(conditions).paginate(:page => requested_page, :per_page => requested_per_page)

    respond_to do |type|
      type.html do
        # index.haml
      end
      type.csv do
        render(:csv => @standing_orders)
      end
    end
  end

  private

  def load_publication
    @publication = Publication.find(params[:publication_id])
  end

  def self.model_class
    StandingOrder
  end
end
