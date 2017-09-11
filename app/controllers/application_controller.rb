# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include Auditor
  before_action(:ensure_logged_in)

  protect_from_forgery

  layout 'default'

  def current_user
    return unless session[:user_email]
    @current_user ||= User.find_by_email(session[:user_email])
  end

  protected

  # Renders a 403 error if the user doesn't have the role
  def require_role(*roles)
    for role in roles
      if current_user.has_role?(role)
        return
      end
    end
    render(status: :forbidden, text: "You do not have permission. Ask for this role: #{roles.join(' ')}")
  end

#  rescue_from(RSolr::RequestError, :with => :render_rsolr_error)
#
  private
#
#  def render_rsolr_error(exception)
#    render(:text => "Sorry, your search didn't work, but it's not your fault nor that of your coworkers! The \"Solr\" people are likely responsible. Please try searching for something else (return to <a href=\"/customers?q=\">the main page</a> to try) and if you have the time, please tell Adam Hooper, <a href=\"mailto:adam@adamhooper.com\">adam@adamhooper.com</a>, what you were searching for when you got this error message and he may be able to fix it. (Just copy-paste the contents of the address bar; that will be enough.)".html_safe)
#  end
end
