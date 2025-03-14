class UserHealthConditionsController < ApplicationController
  before_action :set_user_health_condition, only: %i[show edit update destroy]
  before_action :authenticate_user!

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
    @user_health_condition = current_user.user_health_conditions.build

    # If a new condition name is provided, create it
    if params[:user_health_condition][:new_condition_name].present?
      health_condition = HealthCondition.new(
        health_condition_name: params[:user_health_condition][:new_condition_name]
      )

      if health_condition.save
        @user_health_condition.health_condition = health_condition
      else
        @user_health_condition.errors.merge!(health_condition.errors)
        render :new, status: :unprocessable_entity
        return
      end
    # If an existing condition is selected, use it
    elsif params[:user_health_condition][:health_condition_id].present?
      @user_health_condition.health_condition_id = params[:user_health_condition][:health_condition_id]
    else
      @user_health_condition.errors.add(:base, "Please either select an existing condition or create a new one")
      render :new, status: :unprocessable_entity
      return
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

  def add_health_condition
    @user_health_condition = current_user.user_health_conditions.find(params[:user_health_condition_id])
    @health_condition = HealthCondition.find(params[:health_condition_id])

    if @user_health_condition.health_conditions << @health_condition
      redirect_to @user_health_condition, notice: "Health condition was successfully added."
    else
      redirect_to @user_health_condition, alert: "Failed to add health condition."
    end
  end

  def remove_health_condition
    @user_health_condition = current_user.user_health_conditions.find(params[:user_health_condition_id])
    @health_condition = @user_health_condition.health_conditions.find(params[:id])

    @user_health_condition.health_conditions.delete(@health_condition)
    redirect_to @user_health_condition, notice: "Health condition was successfully removed."
  end

  private

  def set_user_health_condition
    @user_health_condition = current_user.user_health_conditions.find(params[:id])
  end

  def user_health_condition_params
    params.require(:user_health_condition).permit(:health_condition_id, :new_condition_name)
  end
end
