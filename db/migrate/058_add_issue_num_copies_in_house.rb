class AddIssueNumCopiesInHouse < ActiveRecord::Migration
  def self.up
    add_column :issues, :num_copies_in_house, :integer, :null => false, :default => 0
    add_column :issue_versions, :num_copies_in_house, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :issues, :num_copies_in_house
    remove_column :issue_versions, :num_copies_in_house
  end
end
