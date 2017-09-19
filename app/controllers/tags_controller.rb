class TagsController < ApplicationController
  def tag_customers
    tag = Tag.find(params[:id])
    tag.customers << requested_customers
    Sunspot.index(requested_customers)
    head(:no_content)
  end

  def untag_customers
    tag = Tag.find(params[:id])
    tag.customers.delete(requested_customers)
    Sunspot.index(requested_customers)
    head(:no_content)
  end

  private

  def requested_customer_ids
    params[:customer_ids].split(',').reject(&:empty?).map(&:to_i)
  end

  def requested_customers
    @requested_customers = Customer.find(requested_customer_ids)
  end
end
