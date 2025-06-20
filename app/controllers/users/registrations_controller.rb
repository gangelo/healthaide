class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [:update]

  private

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :email, :password, :password_confirmation, :current_password,
      profile_attributes: [ :id, :ai_provider, :ai_provider_model, :ai_provider_api_key ]
    ])
  end
end
