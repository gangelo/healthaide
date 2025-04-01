class UserHealthGoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_health_goal, only: [ :show, :edit, :update, :destroy ]
  before_action :set_user_health_goals, only: [ :index ]

  def index
  end

  def show
  end

  def new
    @user_health_goal = current_user.user_health_goals.build
  end

  def edit
  end

  def create
    if health_goal_params[:health_goal_name].present?
      # Create new health goal
      begin
        @health_goal = HealthGoal.create!(health_goal_name: health_goal_params[:health_goal_name])
        @user_health_goal = current_user.user_health_goals.build(
          health_goal: @health_goal,
          order_of_importance: health_goal_params[:order_of_importance]
        )
      rescue ActiveRecord::RecordInvalid => e
        @user_health_goal = current_user.user_health_goals.build
        @user_health_goal.errors.add(:base, e.record.errors.full_messages.to_sentence)
        render :new, status: :unprocessable_entity
        return
      end
    else
      # Use existing health goal
      @user_health_goal = current_user.user_health_goals.build(
        health_goal_id: health_goal_params[:health_goal_id],
        order_of_importance: health_goal_params[:order_of_importance]
      )
    end

    if @user_health_goal.save
      redirect_to user_health_goals_path, notice: "Health goal was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Only allow updating order_of_importance
    if @user_health_goal.update(order_of_importance: health_goal_params[:order_of_importance])
      redirect_to user_health_goals_path, notice: "Health goal was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_health_goal.destroy
    set_user_health_goals

    respond_to do |format|
      format.html { redirect_to user_health_goals_path, notice: "Health goal was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Health goal was successfully removed."
        render turbo_stream: [
          turbo_stream.update("main_content",
            partial: "user_health_goals/list/list",
            locals: { user_health_goals: @user_health_goals }),
          turbo_stream.update("flash_messages",
            partial: "shared/flash_messages")
        ]
      end
    end
  end

  def select_multiple
    # Get the list of health goals not already selected by the user
    @health_goals = SearchService.search_health_goals(current_user, params[:search])

    respond_to do |format|
      format.html do
        # For a search, render just the goals list in its turbo frame
        if turbo_frame_request? && params[:frame_id] == "goals_list"
          render :_goals_list_frame, locals: { health_goals: @health_goals }
        elsif turbo_frame_request?
          # For the entire modal
          render partial: "multiple_goals_modal", locals: { health_goals: @health_goals }
        end
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "goals_list",
          partial: "goals_list",
          locals: { health_goals: @health_goals }
        )
      end
    end
  end

  def add_multiple
    health_goal_ids = params[:health_goal_ids]&.reject(&:blank?)

    if health_goal_ids.blank?
      error_message = "Please select at least one health goal."
      respond_to do |format|
        format.turbo_stream do
          flash[:alert] = error_message
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages"
          )
        end
        format.html do
          redirect_to user_health_goals_path, alert: error_message
        end
      end
      return
    end

    begin
      # Get maximum order of importance
      max_order = current_user.user_health_goals.maximum(:order_of_importance) || 0

      # Get existing health_goal_ids to avoid duplicates
      existing_health_goal_ids = current_user.user_health_goals.pluck(:health_goal_id)
      new_health_goal_ids = health_goal_ids.map(&:to_i) - existing_health_goal_ids

      # Batch create records for efficiency
      if new_health_goal_ids.any?
        records_to_insert = new_health_goal_ids.each_with_index.map do |health_goal_id, index|
          {
            user_id: current_user.id,
            health_goal_id: health_goal_id,
            order_of_importance: max_order + index + 1,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        # Use insert_all for better performance
        UserHealthGoal.insert_all(records_to_insert) if records_to_insert.any?
        goals_added = records_to_insert.size
      end

      message = "#{goals_added} #{"health goal".pluralize(goals_added)} successfully added."

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = message
          render turbo_stream: [
            turbo_stream.update(
              "flash_messages",
              partial: "shared/flash_messages"
            ),
            turbo_stream.update(
              "main_content",
              partial: "user_health_goals/list/list",
              locals: { user_health_goals: current_user.user_health_goals.ordered_by_importance }
            ),
            turbo_stream.replace(
              "modal",
              partial: "shared/empty_frame"
            )
          ]
        end
        format.html do
          redirect_to user_health_goals_path, notice: message
        end
      end
    rescue => e
      error_message = "Error adding health goals: #{e.message}"
      respond_to do |format|
        format.turbo_stream do
          flash[:alert] = error_message
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages"
          )
        end
        format.html do
          redirect_to user_health_goals_path, alert: error_message
        end
      end
    end
  end

  def update_importance
    new_order = params[:order_of_importance].to_i
    return head :bad_request if new_order <= 0

    current_order = @user_health_goal.order_of_importance

    if new_order > current_order
      # Moving down in importance (higher number)
      UserHealthGoal.where(order_of_importance: (current_order + 1)..new_order)
                   .update_all("order_of_importance = order_of_importance - 1")
    else
      # Moving up in importance (lower number)
      UserHealthGoal.where(order_of_importance: new_order...(current_order))
                   .update_all("order_of_importance = order_of_importance + 1")
    end

    @user_health_goal.update(order_of_importance: new_order)

    head :ok
  end

  private

  def set_user_health_goal
    @user_health_goal = current_user.user_health_goals.find(params[:id])
  end

  def set_user_health_goals
    @user_health_goals = current_user.user_health_goals.ordered_by_importance
  end

  def health_goal_params
    params.require(:user_health_goal).permit(:health_goal_id, :health_goal_name, :order_of_importance)
  end
end
