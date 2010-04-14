class TagController < ApplicationController
  def auto_complete_for_tag_name
    tags = Tag.where('name LIKE ?', Tags.normalize_name(params[:q]) + '%').order(:name).limit(10).all
    render(:text => tags.collect{|t| "#{t.name}|#{t.name} (#{t.num_customers})" }.join("\n"))
  end
end
