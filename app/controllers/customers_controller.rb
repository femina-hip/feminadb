class CustomersController < ApplicationController
  include CustomersQueryRewriter
  include ActsAsReportableControllerHelper

  before_filter :remember_q_and_page, :only => :index

  make_resourceful do
    actions :show, :new, :edit, :create, :update, :destroy
  end

  # GET /customers
  # GET /customers.csv
  # GET /customers.xml
  def index
    q = requested_q
    page = requested_page
    per_page = requested_per_page

    search = Customer.search do
      keywords q
      order_by :region_name_for_sorting
      order_by :district_for_sorting
      order_by :name_for_sorting
      paginate :page => page, :per_page => per_page
    end

    @customers = search.results

    respond_to do |type|
      type.html do
        params[:q] = requested_q
        # render index.haml
      end
      type.csv do
        table = report_table_from_objects(
          @customers,
          :only => [ :id, :name, :district, :deliver_via, :address, :po_box, :contact_name, :contact_position, :telephone_1, :telephone_2, :telephone_3, :fax, :email_1, :email_2, :website ],
          :include => {
            :region => { :only => :name },
            :delivery_method => { :only => [ :abbreviation, :name ] },
            :type => { :only => [ :name, :description ] }
          },
          :order => [
            'id',
            'region.name',
            'district',
            'type.name',
            'type.description',
            'name',
            'delivery_method.abbreviation',
            'delivery_method.name',
            'deliver_via',
            'address',
            'po_box',
            'contact_name',
            'contact_position',
            'telephone_1',
            'telephone_2',
            'telephone_3',
            'fax',
            'email_1',
            'email_2',
            'website'
          ]
        )
        s = table.as(:csv)
        render :text => s
      end
      type.xml  { render :xml => @customers.to_xml }
    end
  end

  private
    def default_includes
      [ :region, :type, :delivery_method ]
    end

    def requested_page
      return params[:page].to_i if params[:page].to_i > 0
      return session[:customers_page] if not params[:q]
      1
    end

    def requested_per_page
      return :all if request.format == Mime::CSV
      Customer.per_page
    end

    def requested_q
      params[:q] || session[:customers_q] || ''
    end

    def remember_q_and_page
      session[:customers_q] = params[:q] if params[:q]
      session[:customers_page] = requested_page
    end
end
