class AddRegionNSchools < ActiveRecord::Migration[5.1]
  def change
    add_column(:regions, :n_schools, :integer, default: 0)
  end
end
