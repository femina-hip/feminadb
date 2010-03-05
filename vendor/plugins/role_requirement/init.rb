# Role authentication system

require "role_requirement_system.rb"

ActionController::Base.send :include, RoleRequirement
