class InsertRoleEditIssues < ActiveRecord::Migration
  def self.up
    Role.create({ :name => 'edit-issues' })
  end

  def self.down
    role = Role.find_by_name('edit-issues')
    if role
      role.destroy
    end
  end
end
