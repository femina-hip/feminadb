class AccountController < ApplicationController
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      redirect_back_or_default '/'
      flash[:notice] = 'Logged in successfully'
    else
      flash[:notice] = 'Incorrect username or password'
    end
  end

  def logout
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    session[:return_to] = params[:return_to] if params[:return_to]
    redirect_back_or_default '/'
  end
end
