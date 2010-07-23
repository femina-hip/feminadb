# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  include RoleRequirement

  protect_from_forgery

  layout 'default'
  require_role 'view'

  rescue_from(RSolr::RequestError, :with => :render_rsolr_error)

  private

  def render_rsolr_error(exception)
    render(:text => "Sorry, your search didn't work, but it's not your fault nor that of your coworkers! The \"Solr\" people are likely responsible. Please try searching for something else and tell Adam Hooper, <a href=\"mailto:adam@adamhooper.com\">adam@adamhooper.com</a>, what you were searching for when you got this error message. (Just copy-paste the contents of the address bar; that will be enough.)".html_safe)
  end
end
