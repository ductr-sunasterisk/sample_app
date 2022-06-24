class PasswordResetsController < ApplicationController
  include SessionsHelper
  before_action :load_user, only: %i(create edit update)
  before_action :valid_user, :check_expiration, only: %i(edit update)
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t ".email_sent"
    redirect_to :root
  end

  def new; end

  def edit; end

  def update
    return update_done if params[:user][:password] && @user.update(user_params)

    @user.errors.add :password, t(".cant_be_empty")
    render :edit
  end

  private
  def load_user
    return if @user = User.find_by(email: params.dig(:password_reset,
      :email)&.downcase || params[:email]&.downcase)

    flash.now[:danger] = t ".email_not_found"
    render :new
  end

  def valid_user
    unless @user.activated? && @user.authenticated?(:reset,
                                                      params[:id])
      flash[:danger] = t ".bad_request"
      redirect_to root_url
    end
  end

  # def get_user
  #   return if @user = User.find_by(email: params[:email].downcase)

  #   flash.now[:danger] = t ".email_not_found"
  #   render :new
  # end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = ".token_time_out"
    redirect_to new_password_reset_url
  end

  def update_done
    log_in @user
    flash[:success] = "password_has_reset."
    redirect_to @user
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end
end
