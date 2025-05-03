class UserHealthConditionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_health_condition, only: %i[show edit update destroy]
  before_action :set_user_health_conditions, only: %i[index]

  def index
  end

  def show
    @available_health_conditions = HealthCondition.where.not(id: @user_health_condition.health_condition_ids)
  end

  def new
    @user_health_condition = current_user.user_health_conditions.build

    # Get all health conditions not already associated with the user
    user_condition_ids = current_user.health_conditions.pluck(:id)
    @health_conditions = HealthCondition.ordered.where.not(id: user_condition_ids)

    # Handle AJAX search requests
    if request.xhr? && params[:search].present?
      @health_conditions = SearchService.search_health_conditions(current_user, params[:search])
      render partial: "search_results", locals: { conditions: @health_conditions }
    end
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
    set_user_health_conditions

    respond_to do |format|
      format.html { redirect_to user_health_conditions_path, notice: "Health condition was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Health condition was successfully removed."
        render turbo_stream: [
          turbo_stream.update("main_content",
            partial: "user_health_conditions/list/list",
            locals: { user_health_conditions: @user_health_conditions }),
          turbo_stream.update("flash_messages",
            partial: "shared/flash_messages")
        ]
      end
    end
  end

  # Custom add_multiple action for the new health condition selection UI
  def add_multiple
    health_condition_ids = params[:health_condition_ids]&.reject(&:blank?)
    new_condition_names = params[:new_condition_names]&.reject(&:blank?)

    if health_condition_ids.blank? && new_condition_names.blank?
      flash[:alert] = "Please select at least one health condition to add."
      redirect_to new_user_health_condition_path
      return
    end

    conditions_added = 0

    # First handle creating any new conditions that don't exist
    if new_condition_names.present?
      new_condition_names.each do |condition_name|
        # Check if condition exists
        condition = HealthCondition.find_by(health_condition_name: HealthCondition.normalize_name(condition_name))
        if condition.nil?
          # Create a new condition
          condition = HealthCondition.create!(health_condition_name: condition_name)
        end

        # Add the condition to the user's list if it's not already there
        unless current_user.user_health_conditions.exists?(health_condition_id: condition.id)
          current_user.user_health_conditions.create!(health_condition_id: condition.id)
          conditions_added += 1
        end
      end
    end

    # Then handle existing conditions
    if health_condition_ids.present?
      # Get existing health_condition_ids to avoid duplicates
      existing_health_condition_ids = current_user.user_health_conditions.pluck(:health_condition_id)
      new_health_condition_ids = health_condition_ids.map(&:to_i) - existing_health_condition_ids

      if new_health_condition_ids.any?
        # Get available condition IDs
        available_condition_ids = HealthCondition.where(id: new_health_condition_ids).pluck(:id)

        records_to_insert = available_condition_ids.map do |health_condition_id|
          { user_id: current_user.id, health_condition_id: health_condition_id, created_at: Time.current, updated_at: Time.current }
        end

        # Use insert_all for better performance
        UserHealthCondition.insert_all(records_to_insert) if records_to_insert.any?
        conditions_added += records_to_insert.size
      end
    end

    # Set success message and redirect
    if conditions_added > 0
      flash[:notice] = "#{conditions_added} #{conditions_added == 1 ? "health condition" : "health conditions"} successfully added."
    else
      flash[:alert] = "No new health conditions were added to your list."
    end

    redirect_to user_health_conditions_path
  end

  private

  def set_user_health_condition
    @user_health_condition = current_user.user_health_conditions.find(params[:id])
  end

  def set_user_health_conditions
    @user_health_conditions = current_user.user_health_conditions.ordered
  end

  def user_health_condition_params
    params.require(:user_health_condition).permit(:health_condition_id, :new_health_condition_name)
  end
end
