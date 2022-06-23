class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private
  def set_locale
    locale = params[:locale].to_s.strip.to_sym
    if I18n.available_locales.include? locale
      I18n.locale = locale
    else
      I18n.default_locale
    end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def not_found
    flash[:danger] = t "layouts.application.not_found"
    redirect_to root_path
  end
end
