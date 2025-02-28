# The application controller for this application.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  add_flash_types :info, :warning, :error

  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_session_timeout
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user|
      user.permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
    end
  end

  private

  def handle_session_timeout
    if request.format.html?
      redirect_to new_user_session_path, alert: "Your session has expired. Please log in again."
    else
      response.headers["Turbo-Stream-Location"] = new_user_session_path
      render json: { error: "session_expired" }, status: :unauthorized
    end
  end
end
