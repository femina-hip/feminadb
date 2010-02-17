class InsertEditSpecialOrdersRole < ActiveRecord::Migration
  def self.up
    Role.create :name => 'edit-special-orders'
  end

  def self.down
    role = Role.find_by_name('edit-special-orders')
    if role
      role.destroy
    end
  end
end
