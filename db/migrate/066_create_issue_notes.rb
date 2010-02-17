class CreateIssueNotes < ActiveRecord::Migration
  def self.up
    create_table :issue_notes, :force => true do |t|
      t.column :issue_id, :integer, :null => false
      t.column :note, :text, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :created_by, :integer
      t.column :deleted_at, :datetime
    end
    add_index :issue_notes, :issue_id
  end

  def self.down
    drop_table :issue_notes
  end
end
