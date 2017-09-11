class AddRegionCouncils < ActiveRecord::Migration[4.2]
  def change
    add_column(:regions, :councils_separated_by_newline, :text)
  end
end
