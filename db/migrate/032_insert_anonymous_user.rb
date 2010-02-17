class InsertAnonymousUser < ActiveRecord::Migration
  def self.up
    User.transaction do
      u = User.new({
          :login => 'anonymous',
          :email => 'feminahip@raha.com',
          :password => 'anonymous',
          :password_confirmation => 'anonymous',
      })
      r = Role.find_by_name('view')
      u.roles << r
      u.save!
    end
  end

  def self.down
    User.transaction do
      User.find_by_login('anonymous').destroy
    end
  end
end
