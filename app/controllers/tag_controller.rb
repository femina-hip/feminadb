class TagController < ApplicationController
  before_filter :login_required

  def auto_complete_for_tag_name
    @tags = Tag.find(
      :all,
      :conditions => [
        'name LIKE ?',
        Tags.normalize_name(params[:tag][:name]) + '%'
      ],
      :order => :name,
      :limit => 10
    )
    render :partial => 'tags'
  end

  def create
    customer = Customer.find(params[:customer_id])

    tag_name = Tags.normalize_name(params[:tag][:name])

    note = customer.notes.build(:note => "TAG_#{tag_name}")

    respond_to do |format|
      if note.save
        flash[:notice] = "Tag #{tag_name} was successfully added."
        format.html { redirect_to customer_url(customer) }
        format.xml  { head :created, :location => customer_url(customer) }
      else
        flash[:notice] = "Tag #{tag_name} could not be added."
        format.html { redirect_to customer_url(customer) }
        format.xml  { head :created, :location => customer_url(customer) }
      end
    end
  end
end
