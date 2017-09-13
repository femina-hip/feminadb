class AddRegionManager < ActiveRecord::Migration[5.1]
  def change
    add_column(:regions, :manager, :string, null: false, default: '')
  end
end
