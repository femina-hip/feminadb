class CreateIssueBoxSizes < ActiveRecord::Migration
  def self.up
    create_table :issue_box_sizes do |t|
      t.column :issue_id, :int
      t.column :num_copies, :int
      t.column :updated_at, :datetime
      t.column :updated_by, :int
      t.column :version, :int
    end
    IssueBoxSize.create_versioned_table
  end

  def self.down
    IssueBoxSize.DROP_versioned_table
    drop_table :issue_box_sizes
  end
end
