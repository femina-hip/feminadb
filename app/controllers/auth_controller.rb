class AuthController < ActionController::Base
  def callback
    oauth_response = OauthStrategy.ask_google_about_code(request)
    email = oauth_response['email']
    if User.find_by_email(email)
      destination = params[:state] || '/'
      session[:user_email] = email
      redirect_to(destination)
    else
      raise Exception, "User #{email} does not exist in FeminaDB. An administrator needs to add you."
    end
  end

  def logout
    session.delete(:user_email)
    redirect_to('/')
  end
end
