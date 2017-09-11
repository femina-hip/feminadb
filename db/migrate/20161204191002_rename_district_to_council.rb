class RenameDistrictToCouncil < ActiveRecord::Migration[4.2]
  def change
    rename_column(:customers, :district, :council)
    rename_column(:orders, :district, :council)
  end
end
