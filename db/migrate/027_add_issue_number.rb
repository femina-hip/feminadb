class AddIssueNumber < ActiveRecord::Migration
  def self.up
    add_column :issues, :issue_number, :integer, :null => false
    add_column :issue_versions, :issue_number, :integer, :null => false

    num = 0
    Issue.find(:all).each do |issue|
      num += 1
      issue.issue_number = num
      issue.save!
    end
  end

  def self.down
    remove_column :issues, :issue_number
    remove_column :issue_versions, :issue_number
  end
end
