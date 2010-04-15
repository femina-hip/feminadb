class AddPrMaterialToPublications < ActiveRecord::Migration
  def self.up
    add_column(:publications, :pr_material, :boolean, :default => true)
  end

  def self.down
    remove_column(:publications, :pr_material)
  end
end
