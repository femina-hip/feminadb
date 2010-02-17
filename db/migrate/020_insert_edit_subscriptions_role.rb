class InsertEditSubscriptionsRole < ActiveRecord::Migration
  def self.up
    Role.create({ :name => 'edit-orders' })
  end

  def self.down
    role = Role.find_by_name('edit-orders')
    if role
      role.destroy
    end
  end
end
