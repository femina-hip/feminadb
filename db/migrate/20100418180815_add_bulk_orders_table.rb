class AddBulkOrdersTable < ActiveRecord::Migration
  def self.up
    create_table(:bulk_order_creators) do |t|
      t.integer(:issue_id)
      t.integer(:from_publication_id)
      t.integer(:from_issue_id)
      t.string(:search_string)
      t.boolean(:constant_num_copies)
      t.integer(:num_copies)
      t.string(:comment)
      t.integer(:delivery_method_id)
      t.date(:order_date)
      t.integer(:created_by)
      t.datetime(:created_at)
      t.datetime(:deleted_at)
      t.string(:status)
      t.datetime(:updated_at) # for status message
    end

    add_index(:bulk_order_creators, :issue_id)
  end

  def self.down
    drop_table(:bulk_order_creators)
  end
end
