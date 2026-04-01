class ApplicationController < ActionController::Base
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :check_session_version

  after_action :verify_authorized, unless: :devise_controller?
  after_action :verify_policy_scoped, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  private

  def check_session_version
    return unless current_user
    return if session[:session_version].blank?
    if current_user.session_version != session[:session_version]
      sign_out current_user
      redirect_to new_user_session_path
    end
  end

  def user_not_authorized
    flash[:alert] = I18n.t("pundit.user_not_authorized")
    redirect_to(request.referrer || root_path)
  end
end
