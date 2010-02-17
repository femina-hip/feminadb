class InsertViewRole < ActiveRecord::Migration
  def self.up
    Role.create({ :name => 'view' })
  end

  def self.down
    role = Role.find_by_name('view')
    if role
      role.destroy
    end
  end
end
