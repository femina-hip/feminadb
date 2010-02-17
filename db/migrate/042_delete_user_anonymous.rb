class DeleteUserAnonymous < ActiveRecord::Migration
  # A complete reversal of 032_insert_anonymous_user.rb

  def self.up
    u = User.find_by_login('anonymous')
    u and u.destroy
  end

  def self.down
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
end
