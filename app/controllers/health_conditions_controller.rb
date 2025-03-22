class HealthConditionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_health_condition, only: %i[show edit update destroy]

  def index
    @health_conditions = HealthCondition.ordered
  end

  def show
  end

  def new
    @health_condition = HealthCondition.new
  end

  def edit
  end

  def create
    @health_condition = HealthCondition.new(health_condition_params)

    if @health_condition.save
      redirect_to health_condition_url(@health_condition), notice: "Health condition was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @health_condition.update(health_condition_params)
      redirect_to health_condition_url(@health_condition), notice: "Health condition was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @health_condition.soft_delete
    redirect_to health_conditions_url, notice: "Health condition was successfully deleted."
  end

  private

  def set_health_condition
    @health_condition = HealthCondition.find(params[:id])
  end

  def health_condition_params
    params.require(:health_condition).permit(:health_condition_name)
  end
end
