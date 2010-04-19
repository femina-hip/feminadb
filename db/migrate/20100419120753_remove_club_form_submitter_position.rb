class RemoveClubFormSubmitterPosition < ActiveRecord::Migration
  def self.up
    remove_column(:clubs, :form_submitter_position)
  end

  def self.down
    add_column(:clubs, :form_submitter_position, :string, :null => false, :default => '')
  end
end
