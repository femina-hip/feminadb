class ClubsController < ApplicationController
  include CustomerFilterControllerMethods

  require_role 'edit-customers', :except => [ :index, :show ]

  # GET /clubs
  # GET /clubs.csv
  # GET /clubs.xml
  def index
    conditions = {}

    customers = search_for_customers(
      :includes => [ :region, :club ],
      :order => [ :region, :district, :name ]
    ) do
      with(:club, true)
    end

    @clubs = customers.dup # WillPaginate magic
    @clubs.replace(customers.collect(&:club))

    respond_to do |format|
      format.html # index.html.haml
      format.csv do
        Club.send(:preload_associations, @clubs, :customer => [ :type, :delivery_method ])
        render(:csv => @clubs)
      end
      format.xml  { render :xml => @clubs }
    end
  end

  # GET /clubs/1
  # GET /clubs/1.xml
  def show
    @club = Club.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @club }
    end
  end

  # GET /clubs/new?customer_id=1
  # GET /clubs/new.xml?customer_id=1
  def new
    customer = Customer.find(params[:customer_id].to_i)
    @club = customer.build_club

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @club }
    end
  end

  # GET /clubs/1/edit
  def edit
    @club = Club.find(params[:id])
  end

  # POST /clubs
  # POST /clubs.xml
  def create
    @club = Club.new(params[:club].merge(:updated_by => current_user))

    respond_to do |format|
      if @club.save
        flash[:notice] = 'Club was successfully created.'
        format.html { redirect_to(@club.customer) }
        format.xml  { render :xml => @club, :status => :created, :location => @club }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @club.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clubs/1
  # PUT /clubs/1.xml
  def update
    @club = Club.find(params[:id])

    respond_to do |format|
      if @club.update_attributes(params[:club].merge(:updated_by => current_user))
        flash[:notice] = 'Club was successfully updated.'
        format.html { redirect_to(@club.customer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @club.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clubs/1
  # DELETE /clubs/1.xml
  def destroy
    @club = Club.find(params[:id])
    customer_id = @club.customer_id

    @club.soft_delete(:updated_by => current_user)

    respond_to do |format|
      format.html { redirect_to(customer_url(customer_id)) }
      format.xml  { head :ok }
    end
  end

  def self.model_class
    Club
  end
end
