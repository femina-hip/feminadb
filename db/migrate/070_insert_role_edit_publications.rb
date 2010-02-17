class InsertRoleEditPublications < ActiveRecord::Migration
  def self.up
    Role.create({ :name => 'edit-publications' })
  end

  def self.down
    role = Role.find_by_name('edit-publications')
    if role
      role.destroy
    end
  end
end
