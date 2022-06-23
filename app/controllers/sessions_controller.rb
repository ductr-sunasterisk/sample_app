class SessionsController < ApplicationController
  include SessionsHelper
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase

    if user&.authenticate params.dig(:session, :password)
      log_in user
      remember_user user
      redirect_back_or user
    else
      flash.now[:danger] = t ".invalid_email_password_combination"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  def remember_user user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
  end
end
