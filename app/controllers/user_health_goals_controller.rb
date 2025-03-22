class UserHealthGoalsController < ApplicationController
  before_action :set_user_health_goal, only: [ :show, :edit, :update, :destroy ]
  before_action :authenticate_user!

  def index
    @user_health_goals = current_user.user_health_goals.ordered_by_importance
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
      @health_goal = HealthGoal.create!(health_goal_name: health_goal_params[:health_goal_name])
      @user_health_goal = current_user.user_health_goals.build(
        health_goal: @health_goal,
        order_of_importance: health_goal_params[:order_of_importance]
      )
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
    if @user_health_goal.update(health_goal_params)
      redirect_to user_health_goals_path, notice: "Health goal was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_health_goal.destroy
    redirect_to user_health_goals_url, notice: "Health goal was successfully removed."
  end

  def add_multiple
    health_goal_ids = params[:health_goal_ids]

    if health_goal_ids.blank?
      redirect_to new_user_health_goal_path, alert: "Please select at least one health goal"
      return
    end

    max_order = current_user.user_health_goals.maximum(:order_of_importance) || 0

    created_goals = health_goal_ids.each_with_index.map do |goal_id, index|
      current_user.user_health_goals.create(
        health_goal_id: goal_id,
        order_of_importance: max_order + index + 1
      )
    end

    if created_goals.all?(&:persisted?)
      redirect_to user_health_goals_path, notice: "#{created_goals.count} health goals were successfully added"
    else
      redirect_to new_user_health_goal_path, alert: "There was an error adding some health goals"
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

  def health_goal_params
    params.require(:user_health_goal).permit(:health_goal_id, :health_goal_name, :order_of_importance)
  end
end
