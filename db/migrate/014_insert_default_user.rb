class InsertDefaultUser < ActiveRecord::Migration
  def self.up
    admin_role = Role.create({:name => 'admin'})
    admin_user = User.create ({
        :login => 'admin',
        :email => 'adamh@densi.com',
        :password => 'admin',
        :password_confirmation => 'admin',
    })
    admin_user.roles << admin_role
    admin_user.save!
  end

  def self.down
    admin = User.find_by_name('admin')
    if admin
      admin.destroy
    end
    admin_role = Role.find_by_name('admin')
    if admin_role
      admin_role.destroy
    end
  end
end
