class ExportsController < ApplicationController
  USER_FOODS_EXPORT_OPTION = 1
  USER_HEALTH_CONDITIONS_EXPORT_OPTION = 2
  USER_HEALTH_GOALS_EXPORT_OPTION = 3

  before_action :authenticate_admin!
  before_action :set_users, only: [ :index ]
  before_action :set_export_options, only: [ :index ]

  def index
    @selected_user_export_hash = current_user.to_export_hash
  end

  def preview
    selected_user_export_hash = {}

    user = User.find_by(id: params[:user_id])
    if user
      export_options = params[:export_options] || []
      selected_user_export_hash = user.to_export_hash
      selected_user_export_hash[:user].delete(:user_foods) unless export_options.include?(USER_FOODS_EXPORT_OPTION.to_s)
      selected_user_export_hash[:user].delete(:user_health_conditions) unless export_options.include?(USER_HEALTH_CONDITIONS_EXPORT_OPTION.to_s)
      selected_user_export_hash[:user].delete(:user_health_goals) unless export_options.include?(USER_HEALTH_GOALS_EXPORT_OPTION.to_s)
    end

    render partial: "exports/preview", locals: { selected_user_export_hash: selected_user_export_hash }
  end

  def export
    # TODO: Implement export functionality
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
end
