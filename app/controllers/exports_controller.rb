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
      # # Your logic to build the export hash based on selected options
      # # For example:
      # @selected_user_export_hash = {
      #   user: { id: @user.id, username: @user.username },
      #   exports: @selected_options.map do |option|
      #     { type: option, data: get_export_data(@user, option) }
      #   end
      # }
      @selected_user_export_hash
    end

    render partial: "exports/preview", locals: { selected_user_export_hash: @selected_user_export_hash }
    # render "exports/export_json", selected_user_export_hash: @selected_user_export_hash
  end

  def export
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
