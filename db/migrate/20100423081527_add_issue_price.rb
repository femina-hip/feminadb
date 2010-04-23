class AddIssuePrice < ActiveRecord::Migration
  def self.up
    add_column(:issues, :price, :decimal, :precision => 12, :scale => 0)
  end

  def self.down
    remove_column(:issues, :price)
  end
end
