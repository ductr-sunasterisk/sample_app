class UsersController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  before_action :logged_in_user, only: %i(index edit update)
  before_action :load_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(User.latest_users)
  end

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to login_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t "update_successed"
      redirect_to @user
    else
      flash.now[:danger] = t "update_failed"
      render :edit
    end
  end

  def logged_in_user
    return unless logged_in? do
      store_location
      flash[:danger] = t "users.user.log_in_first"
      redirect_to login_url
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "users.user.delete_success"
    else
      flash[:danger] = t "users.user.delete_fail"
    end
    redirect_to users_url
  end

  private

  def admin_user
    return unless current_user.admin?

    flash[:danger] = t "users.user.not_permitted"
    redirect_to(root_path)
  end

  def correct_user
    return unless current_user?(@user)

    flash[:danger] = t ".not_permitted"
    redirect_to(root_url)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def load_user
    unless @user = User.find_by(id: params[:id])
      flash[:danger] = t ".bad_request"
      redirect_to :root
    end
  end
end
