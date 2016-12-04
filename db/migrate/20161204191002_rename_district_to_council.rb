class RenameDistrictToCouncil < ActiveRecord::Migration
  def change
    rename_column(:customers, :district, :council)
    rename_column(:orders, :district, :council)
  end
end
