class Admin::UsersController < ApplicationController
  def index
    require_role 'admin'
    @users = User.order(:login).all
  end

  def new
    require_role 'admin'
    @user = User.new
  end

  def edit
    require_role 'admin'
    @user = user
  end

  def create
    require_role 'admin'
    @user = create_with_audit(User, user_params)
    if @user.valid?
      redirect_to(admin_users_url)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'admin'
    if update_with_audit(user, user_params)
      redirect_to(admin_users_url)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'admin'
    if user.email == current_user.email
      flash[:notice] = 'You cannot delete yourself. Phew.'
    else
      destroy_with_audit(user)
    end
    redirect_to(admin_users_url)
  end

  private

  def user
    @user ||= User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:login, :email)
  end
end
