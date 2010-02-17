class ChangeIssueIssueNumberToVarchar < ActiveRecord::Migration
  def self.up
    change_column :issues, :issue_number, :string, :null => false, :default => ''
    change_column :issue_versions, :issue_number, :string, :null => false, :default => ''
  end

  def self.down
    change_column :issues, :issue_number, :integer
    change_column :issue_versions, :issue_number, :integer
  end
end
