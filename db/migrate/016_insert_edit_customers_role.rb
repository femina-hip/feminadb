class InsertEditCustomersRole < ActiveRecord::Migration
  def self.up
    Role.create({ :name => 'edit-customers' })
  end

  def self.down
    role = Role.find_by_name('edit-customers')
    if role
      role.destroy
    end
  end
end
