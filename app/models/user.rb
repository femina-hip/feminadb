class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :order => :name

  validates_presence_of :email
  validates_length_of :email, :within => 3..100
  validates_uniqueness_of :email, case_sensitive: false

  def role_names
    @role_names ||= roles.map(&:name)
  end

  def has_role?(role_name)
    role_names.include?(role_name) || role_names.include?('admin')
  end
end
