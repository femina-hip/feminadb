class CreateWarehouseIssueBoxSizes < ActiveRecord::Migration
  def self.up
    create_table :warehouse_issue_box_sizes do |t|
      t.column :warehouse_id, :integer
      t.column :issue_box_size_id, :integer
      t.column :issue_id, :integer
      t.column :num_boxes, :integer
      t.column :num_copies, :integer
      t.column :updated_by, :integer
      t.column :updated_at, :datetime
      t.column :deleted_at, :datetime
    end
    WarehouseIssueBoxSize.create_versioned_table
    Role.create({ :name => 'edit-inventory' })
  end

  def self.down
    role = Role.find_by_name('edit-inventory')
    if role
      role.destroy
    end

    WarehouseIssueBoxSize.drop_versioned_table
    drop_table :warehouse_issue_box_sizes
  end
end
