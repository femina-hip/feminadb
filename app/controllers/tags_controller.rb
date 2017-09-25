class TagsController < ApplicationController
  def tag_customers
    tag = Tag.find(params[:id])
    requested_customers.each do |customer|
      old_attributes = customer.attributes
      customer.tags << tag
      audit_update(customer, old_attributes, customer.attributes)
    end
    Sunspot.index(requested_customers)
    head(:no_content)
  end

  def untag_customers
    tag = Tag.find(params[:id])
    requested_customers.each do |customer|
      old_attributes = customer.attributes
      customer.tags.delete(tag)
      audit_update(customer, old_attributes, customer.attributes)
    end
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
