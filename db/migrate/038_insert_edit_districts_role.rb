class InsertEditDistrictsRole < ActiveRecord::Migration
  def self.up
    Role.create({ :name => 'edit-districts' })
  end

  def self.down
    role = Role.find_by_name('edit-districts')
    if role
      role.destroy
    end
  end
end
