class HealthGoalsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_health_goal, only: [ :show, :edit, :update, :destroy ]

  def index
    @health_goals = HealthGoal.ordered
  end

  def show
  end

  def new
    @health_goal = HealthGoal.new
  end

  def edit
  end

  def create
    @health_goal = HealthGoal.new(health_goal_params)

    if @health_goal.save
      redirect_to health_goals_path, notice: "Health goal was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @health_goal.update(health_goal_params)
      redirect_to health_goals_path, notice: "Health goal was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_goal.destroy
    redirect_to health_goals_path, notice: "Health goal was successfully deleted."
  end

  private

  def set_health_goal
    @health_goal = HealthGoal.find(params[:id])
  end

  def health_goal_params
    params.require(:health_goal).permit(:health_goal_name)
  end
end
