class AccountActivationsController < ApplicationController
  include SessionsHelper
  before_action :load_user

  def edit
    active_account if !@user.activated? && @user.authenticated?(:activation,
                                                                params[:id])
  end

  private

  def active_account
    @user.update_columns activated: true, activated_at: Time.zone.now
    log_in @user
    flash[:success] = t ".account_activated"
    redirect_to :root
  end

  def load_user
    return if @user = User.find_by(email: params[:email])

    flash[:danger] = t ".bad_request"
    redirect_to :root
  end
end
