class Admin::TagsController < ApplicationController
  def index
    require_role 'admin'
    @tags = Tag.all.order(:name)
  end

  def new
    require_role 'admin'
    @tag = Tag.new
  end

  def edit
    require_role 'admin'
    @tag = Tag.find(params[:id])
  end

  def create
    require_role 'admin'
    @tag = create_with_audit(Tag, tag_params)
    if @tag.valid?
      redirect_to(admin_tags_url)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'admin'
    @tag = Tag.find(params[:id])
    if update_with_audit(@tag, tag_params)
      Sunspot.index(@tag.customers)
      redirect_to(admin_tags_url)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'admin'
    tag = Tag.find(params[:id])
    if tag.customers.length > 0
      flash[:notice] = 'Could not delete Tag: it is used by some Customers'
    else
      destroy_with_audit(tag)
    end
    redirect_to(admin_tags_url)
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end
