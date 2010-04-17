class Admin::DistrictsController < ApplicationController
  require_role 'edit-districts'

  # GET /districts
  # GET /districts.xml
  def index
    @districts = District.active.includes(:region).order('regions.name, districts.name').all

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @districts.to_xml }
    end
  end

  # GET /districts/1
  # GET /districts/1.xml
  def show
    @district = District.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @district.to_xml }
    end
  end

  # GET /districts/new
  def new
    @district = District.new
  end

  # GET /districts/1;edit
  def edit
    @district = District.find(params[:id])
  end

  # POST /districts
  # POST /districts.xml
  def create
    @district = District.new(params[:district].merge(:updated_by => current_user))

    respond_to do |format|
      if @district.save
        flash[:notice] = 'District was successfully created.'
        format.html { redirect_to admin_district_url(@district) }
        format.xml  { head :created, :location => admin_district_url(@district) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @district.errors.to_xml }
      end
    end
  end

  # PUT /districts/1
  # PUT /districts/1.xml
  def update
    @district = District.find(params[:id])

    respond_to do |format|
      if @district.update_attributes(params[:district].merge(:updated_by => current_user))
        flash[:notice] = 'District was successfully updated.'
        format.html { redirect_to admin_district_url(@district) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @district.errors.to_xml }
      end
    end
  end

  # DELETE /districts/1
  # DELETE /districts/1.xml
  def destroy
    @district = District.find(params[:id])

    @district.soft_delete!(:updated_by => current_user)

    respond_to do |format|
      format.html { redirect_to admin_districts_url }
      format.xml  { head :ok }
    end
  end
end
