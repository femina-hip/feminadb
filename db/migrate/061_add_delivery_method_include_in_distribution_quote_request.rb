class AddDeliveryMethodIncludeInDistributionQuoteRequest < ActiveRecord::Migration
  def self.up
    add_column :delivery_methods, :include_in_distribution_quote_request, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :delivery_methods, :include_in_distribution_quote_request
  end
end
