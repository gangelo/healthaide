class ImportsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_users, only: [ :index ]
  before_action :set_import_options, only: [ :index ]
  before_action :set_import_user, only: [ :import, :preview ]

  USER_FOODS_IMPORT_OPTION = 1
  USER_HEALTH_CONDITIONS_IMPORT_OPTION = 2
  USER_HEALTH_GOALS_IMPORT_OPTION = 3
  USER_SUPPLEMENTS_IMPORT_OPTION = 4
  USER_STATS_IMPORT_OPTION = 5

  def index
  end

  def preview
    user_import_hash = {}

    if @import_user
      import_options = params[:import_options] || []
      user_import_hash = @import_user.to_import_hash
      user_import_hash = filter_user_import_hash(user_import_hash:, import_options:)
    end

    redacted_user_import_hash = redact_user_import_hash(user_import_hash)

    render partial: "imports/preview", locals: { user_import_hash: redacted_user_import_hash }
  end

  def import
    user_import_hash = {}

    if @import_user
      import_options = params[:import_options]&.values || []
      user_import_hash = @import_user.to_import_hash
      user_import_hash = filter_user_import_hash(user_import_hash:, import_options:)
    end

    json = JSON.pretty_generate(redact_user_import_hash(user_import_hash))
    send_data json,
      filename: "#{@import_user.username}.json",
      type: "application/json",
      disposition: "attachment"
  end

  private

  def set_users
    @users = User.all
  end

  def set_import_options
    @import_options = {
      user_foods: USER_FOODS_IMPORT_OPTION,
      user_health_conditions: USER_HEALTH_CONDITIONS_IMPORT_OPTION,
      user_health_goals: USER_HEALTH_GOALS_IMPORT_OPTION,
      user_supplements: USER_SUPPLEMENTS_IMPORT_OPTION,
      user_stats: USER_STATS_IMPORT_OPTION
    }
  end

  def set_import_user
    @import_user = User.find_by(id: params[:user_id])
  end

  def filter_user_import_hash(user_import_hash:, import_options:)
    user_import_hash.tap do |hash|
      hash[:user].delete(:user_foods) unless import_options.include?(USER_FOODS_IMPORT_OPTION.to_s)
      hash[:user].delete(:user_health_conditions) unless import_options.include?(USER_HEALTH_CONDITIONS_IMPORT_OPTION.to_s)
      hash[:user].delete(:user_health_goals) unless import_options.include?(USER_HEALTH_GOALS_IMPORT_OPTION.to_s)
      hash[:user].delete(:user_supplements) unless import_options.include?(USER_SUPPLEMENTS_IMPORT_OPTION.to_s)
      hash[:user].delete(:user_stat) unless import_options.include?(USER_STATS_IMPORT_OPTION.to_s)
    end
  end

  def redact_user_import_hash(user_import_hash)
    return {} unless user_import_hash.present?

    redacted = "[REDACTED]"
    user_import_hash.tap do |hash|
      hash[:user][:confirmation_token] = redacted
      hash[:user][:encrypted_password] = redacted
      hash[:user][:reset_password_token] = redacted
      hash[:user][:unlock_token] = redacted
    end
  end
end
