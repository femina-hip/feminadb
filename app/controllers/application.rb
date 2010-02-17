# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirement

  include ExceptionNotifiable

  around_filter :retardase_inhibitor # Bug #18

  before_filter :set_user_current_user

  protect_from_forgery

  layout 'default'
  require_role 'view'

  private
    def set_user_current_user
      # http://delynnberry.com/projects/userstamp
      User.current_user = current_user
    end
end
