class DeleteOldVersioningStuff < ActiveRecord::Migration
  def self.up
    unversion_table(:clubs)
    unversion_table(:customer_types)
    unversion_table(:customers)
    unversion_table(:districts)
    unversion_table(:issue_box_sizes)
    unversion_table(:issues)
    unversion_table(:orders)
    unversion_table(:publications)
    unversion_table(:regions)
    unversion_table(:special_order_lines)
    unversion_table(:special_orders)
    unversion_table(:standing_orders)
    unversion_table(:waiting_orders)
    unversion_table(:warehouse_issue_box_sizes)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new('Those old versions are gone now')
  end

  private

  def self.unversion_table(table)
    drop_table("#{table.to_s.singularize}_versions".to_sym)
    remove_column(table, :updated_at)
    remove_column(table, :updated_by)
    remove_column(table, :version)
  end
end
