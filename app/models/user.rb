class User < ActiveRecord::Base
  validates_presence_of :email
  validates_length_of :email, :within => 3..100
  validates_uniqueness_of :email, case_sensitive: false
  validates_format_of :roles,
    with: /\A(admin|edit-(customers|issues|orders))?( (admin|edit-(customers|issues|orders)))*\z/,
    message: 'must be space-separated list of admin, edit-customers, edit-issues, edit-orders'

  def login
    @login ||= email.split(/@/)[0]
  end

  def roles_set
    @roles_set ||= (roles || '').split(/ /).to_set
  end

  def has_role?(role_name)
    roles_set.include?(role_name) || roles_set.include?('admin')
  end
end
