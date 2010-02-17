class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.column :customer_id, :int
      t.column :issue_id, :int
      t.column :permanent_request_id, :int
      t.column :num_copies, :int
      t.column :comments, :string
      t.column :request_date, :date
      t.column :request_status_id, :int
      t.column :updated_at, :datetime
      t.column :updated_by, :int
      t.column :version, :int
    end
    Request.create_versioned_table
  end

  def self.down
    Request.drop_versioned_table
    drop_table :requests
  end
end
