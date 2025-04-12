class ExportsController < ApplicationController
  USER_FOODS_EXPORT_OPTION = 1
  USER_HEALTH_CONDITIONS_EXPORT_OPTION = 2
  USER_HEALTH_GOALS_EXPORT_OPTION = 3

  before_action :authenticate_admin!
  before_action :set_users, only: [ :index ]
  before_action :set_export_options, only: [ :index ]
  before_action :set_export_user, only: [ :export, :preview ]

  def index
    @user_export_hash = redact_user_export_hash(current_user.to_export_hash)
  end

  def preview
    user_export_hash = {}

    if @export_user
      export_options = params[:export_options] || []
      user_export_hash = @export_user.to_export_hash
      user_export_hash = filter_user_export_hash(user_export_hash:, export_options:)
    end

    redacted_user_export_hash = redact_user_export_hash(user_export_hash)

    render partial: "exports/preview", locals: { user_export_hash: redacted_user_export_hash }
  end

  def export
    user_export_hash = {}

    if @export_user
      export_options = params[:export_options]&.values || []
      user_export_hash = @export_user.to_export_hash
      user_export_hash = filter_user_export_hash(user_export_hash:, export_options:)
    end

    json = JSON.pretty_generate(redact_user_export_hash(user_export_hash))
    send_data json,
      filename: "#{@export_user.username}.json",
      type: "application/json",
      disposition: "attachment"
  end

  private

  def set_users
    @users = User.all
  end

  def set_export_options
    @export_options = {
      user_foods: USER_FOODS_EXPORT_OPTION,
      user_health_conditions: USER_HEALTH_CONDITIONS_EXPORT_OPTION,
      user_health_goals: USER_HEALTH_GOALS_EXPORT_OPTION
    }
  end

  def set_export_user
    @export_user = User.find_by(id: params[:user_id])
  end

  def filter_user_export_hash(user_export_hash:, export_options:)
    user_export_hash.tap do |hash|
      hash[:user].delete(:user_foods) unless export_options.include?(USER_FOODS_EXPORT_OPTION.to_s)
      hash[:user].delete(:user_health_conditions) unless export_options.include?(USER_HEALTH_CONDITIONS_EXPORT_OPTION.to_s)
      hash[:user].delete(:user_health_goals) unless export_options.include?(USER_HEALTH_GOALS_EXPORT_OPTION.to_s)
    end
  end

  def redact_user_export_hash(user_export_hash)
    return {} unless user_export_hash.present?

    redacted = "[REDACTED]"
    user_export_hash.tap do |hash|
      hash[:user][:confirmation_token] = redacted
      hash[:user][:encrypted_password] = redacted
      hash[:user][:reset_password_token] = redacted
      hash[:user][:unlock_token] = redacted
    end
  end
end
