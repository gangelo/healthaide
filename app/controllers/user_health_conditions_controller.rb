class UserHealthConditionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_health_condition, only: %i[show edit update destroy]

  def index
    @user_health_conditions = current_user.user_health_conditions.ordered
  end

  def show
    @available_health_conditions = HealthCondition.where.not(id: @user_health_condition.health_condition_ids)
  end

  def new
    @user_health_condition = current_user.user_health_conditions.build
  end

  def edit
  end

  def create
    @user_health_condition = current_user.user_health_conditions.build(user_health_condition_params)

    # If a new condition name is provided, create it
    if params[:user_health_condition][:new_health_condition_name].present?
      health_condition = HealthCondition.create(
        health_condition_name: params[:user_health_condition][:new_health_condition_name]
      )

      if health_condition.persisted?
        @user_health_condition.health_condition = health_condition
      else
        @user_health_condition.errors.merge!(health_condition.errors)
        render :new, status: :unprocessable_entity
        return
      end
    end

    if @user_health_condition.save
      redirect_to user_health_conditions_path, notice: "Health condition was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user_health_condition.update(user_health_condition_params)
      redirect_to user_health_conditions_path, notice: "Health condition was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_health_condition.destroy
    redirect_to user_health_conditions_url, notice: "Health condition was successfully removed."
  end

  def select_multiple
    # Use SearchService to get health conditions with search applied if needed
    @health_conditions = SearchService.search_health_conditions(current_user, params[:search])

    respond_to do |format|
      format.html do
        # For a search, render just the conditions list in its turbo frame
        if turbo_frame_request? && params[:frame_id] == "conditions_list"
          render :_conditions_list_frame, locals: { health_conditions: @health_conditions }
        elsif turbo_frame_request?
          # For the entire modal
          render partial: "multiple_conditions_modal", locals: { health_conditions: @health_conditions }
        end
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "conditions_list",
          partial: "conditions_list",
          locals: { health_conditions: @health_conditions }
        )
      end
    end
  end

  def add_multiple
    health_condition_ids = params[:health_condition_ids]&.reject(&:blank?)

    if health_condition_ids.blank?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { alert: "Please select at least one health condition." }
          )
        end
        format.html do
          redirect_to user_health_conditions_path, alert: "Please select at least one health condition."
        end
      end
      return
    end

    begin
      # Get existing health_condition_ids to avoid duplicates
      existing_health_condition_ids = current_user.user_health_conditions.pluck(:health_condition_id)
      new_health_condition_ids = health_condition_ids.map(&:to_i) - existing_health_condition_ids

      # Batch create records for efficiency
      if new_health_condition_ids.any?
        records_to_insert = new_health_condition_ids.map do |health_condition_id|
          {
            user_id: current_user.id,
            health_condition_id: health_condition_id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        # Use insert_all for better performance
        UserHealthCondition.insert_all(records_to_insert) if records_to_insert.any?
        conditions_added = records_to_insert.size
      end

      message = "#{conditions_added} #{"health condition".pluralize(conditions_added)} successfully added."

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "flash_messages",
              partial: "shared/flash_messages",
              locals: { notice: message }
            ),
            turbo_stream.replace(
              "modal",
              partial: "shared/empty_frame"
            )
          ]
        end
        format.html do
          redirect_to user_health_conditions_path, notice: message
        end
      end
    rescue => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { alert: "Error adding health conditions: #{e.message}" }
          )
        end
        format.html do
          redirect_to user_health_conditions_path, alert: "Error adding health conditions: #{e.message}"
        end
      end
    end
  end

  private

  def set_user_health_condition
    @user_health_condition = current_user.user_health_conditions.find(params[:id])
  end

  def user_health_condition_params
    params.require(:user_health_condition).permit(:health_condition_id, :new_health_condition_name)
  end
end
