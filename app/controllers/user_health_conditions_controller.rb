class UserHealthConditionsController < ApplicationController
  include MultipleSelection
  
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

  # Implementation of the MultipleSelection concern methods
  private
  
  def resource_type
    :health_condition
  end
  
  def resource_path
    "user_health_conditions"
  end
  
  def search_items_for_user(query)
    SearchService.search_health_conditions(current_user, query)
  end
  
  def add_items_to_user(health_condition_ids)
    # Get existing health_condition_ids to avoid duplicates
    existing_health_condition_ids = current_user.user_health_conditions.pluck(:health_condition_id)
    new_health_condition_ids = health_condition_ids.map(&:to_i) - existing_health_condition_ids
    
    conditions_added = 0
    
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
    
    conditions_added
  end
  
  # Override the items_local_name to use the correct variable name in view templates
  def items_local_name
    "health_conditions"
  end
  
  # Override the list_frame_id to use the correct frame ID
  def list_frame_id
    "health_conditions_list"
  end
  
  # Override the current_user_items method to ensure proper ordering
  def current_user_items
    current_user.user_health_conditions.ordered
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
