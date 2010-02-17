class InstallActsAsParanoid < ActiveRecord::Migration
  tables = [
    :customers, :customer_versions,
    :issue_box_sizes, :issue_box_size_versions,
    :issues, :issue_versions,
    :publications, :publication_versions,
    :regions, :region_versions,
    :requests, :request_versions,
    :subscriptions, :subscription_versions,
    :users, :user_versions,
  ]

  def self.up
    tables.each do |t|
      add_column t, :deleted_at, :datetime
    end
  end

  def self.down
    tables.each do |t|
      remove_column t, :deleted_at
    end
  end
end
