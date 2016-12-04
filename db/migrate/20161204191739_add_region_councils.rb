class AddRegionCouncils < ActiveRecord::Migration
  def change
    add_column(:regions, :councils_separated_by_newline, :text)
  end
end
