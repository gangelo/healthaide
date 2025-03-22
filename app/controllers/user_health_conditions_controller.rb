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
    @health_conditions = HealthCondition.ordered.where.not(id: current_user.user_health_conditions.pluck(:health_condition_id))

    if params[:search].present?
      @health_conditions = @health_conditions.where("health_condition_name ILIKE ?", "%#{params[:search]}%")
      render turbo_stream: turbo_stream.replace("conditions_list", partial: "conditions_list", locals: { health_conditions: @health_conditions })
    end
  end

  def add_multiple
    health_condition_ids = params[:health_condition_ids]

    if health_condition_ids.blank?
      redirect_to new_user_health_condition_path, alert: "Please select at least one health condition"
      return
    end

    max_order = current_user.user_health_conditions.maximum(:order_of_importance) || 0

    created_conditions = health_condition_ids.each_with_index.map do |condition_id, index|
      current_user.user_health_conditions.create(
        health_condition_id: condition_id,
        order_of_importance: max_order + index + 1
      )
    end

    if created_conditions.all?(&:persisted?)
      redirect_to user_health_conditions_path, notice: "#{created_conditions.count} health conditions were successfully added"
    else
      redirect_to new_user_health_condition_path, alert: "There was an error adding some health conditions"
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
