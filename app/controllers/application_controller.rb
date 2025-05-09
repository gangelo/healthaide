# The application controller for this application.
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  add_flash_types :info, :warning, :error
  include DecoratorHelper

  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_session_timeout
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:first_name, :last_name, :username, :email, :password, :password_confirmation)
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

  def handle_record_not_found
    if request.format.html?
      redirect_to root_path, alert: "The requested resource was not found."
    else
      render json: { error: "not_found" }, status: :not_found
    end
  end

  def authenticate_admin!
    authenticate_user!
    return if current_user.admin?

    # TODO: Redirects are not occurring when auth fails; could be upon turbo request.
    redirect_to root_path,
      flash: { error: "You are not authorized to access this page." },
      status: :forbidden
  end
end
