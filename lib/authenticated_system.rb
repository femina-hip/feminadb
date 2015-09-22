module AuthenticatedSystem
  protected

  # Accesses the current user from the session.
  def current_user
    @current_user
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :ensure_logged_in
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_filter :ensure_logged_in
  #
  def ensure_logged_in
    # may redirect, which ends all filters
    t = OauthStrategy.authenticate(request)
    code = t[0]
    arg = t[1]
    case code
    when 'redirect' then redirect_to(arg)
    when 'user' then @current_user = arg
    end
  end
  
  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied

    respond_to do |accepts|
      accepts.html do
        store_location
        redirect_to :controller => '/account', :action => 'login'
      end
    end
    false
  end  

  # Inclusion hook to make #current_user available as ActionView helper methods.
  def self.included(base)
    base.send(:helper_method, :current_user)
  end
end
