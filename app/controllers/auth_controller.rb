class AuthController < ActionController::Base
  def callback
    oauth_response = OauthStrategy.ask_google_about_code(request)
    email = oauth_response['email']
    User.find_or_create_by!(email: email)
    destination = params[:state] || '/'
    session[:user_email] = email
    redirect_to(destination)
  end

  def logout
    session.delete(:user_email)
    redirect_to('/')
  end
end
