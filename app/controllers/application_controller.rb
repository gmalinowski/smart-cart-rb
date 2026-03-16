class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :check_session_version


  def check_session_version
    return unless current_user
    if current_user.session_version != session[:session_version]
      sign_out current_user
      redirect_to new_user_session_path
    end
  end
end
