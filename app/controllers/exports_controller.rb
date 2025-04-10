class ExportsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_users, only: [ :index ]
  before_action :set_export_options, only: [ :index ]

  def index
    @selected_user_export_hash = current_user.to_export_hash
  end

  def preview
    @user = User.find_by(id: params[:user_id])
    @selected_options = params[:export_options] || []

    @selected_user_export_hash = {}
    if @user.present? && @selected_options.any?
      @selected_user_export_hash = @user.to_export_hash
    end

    render partial: "exports/preview", locals: { selected_user_export_hash: @selected_user_export_hash }
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
      foods: 1,
      health_conditions: 2,
      health_goals: 3
    }
  end
end
