class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.column :name, :string
      t.column :publication_id, :integer
      t.column :issue_date, :date
      t.column :updated_at, :datetime
      t.column :updated_by, :int
      t.column :version, :int
    end
    Issue.create_versioned_table
  end

  def self.down
    Issue.drop_versioned_table
    drop_table :issues
  end
end
