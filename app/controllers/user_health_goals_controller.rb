class UserHealthGoalsController < ApplicationController
  include MultipleSelection

  before_action :authenticate_user!
  before_action :set_user_health_goal, only: [ :show, :edit, :update, :destroy ]
  before_action :set_user_health_goals, only: [ :index ]

  def index
  end

  def show
  end

  def new
    @user_health_goal = current_user.user_health_goals.build
    @health_goals = HealthGoal.ordered.where.not(id: current_user.user_health_goals.pluck(:health_goal_id))

    # Handle AJAX search requests
    if request.xhr? && params[:search].present?
      @health_goals = @health_goals.where("health_goal_name LIKE ?", "%#{params[:search]}%")
      render partial: "search_results", locals: { goals: @health_goals }
    end
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
  
  # Add multiple action for the health goal selection UI
  def add_multiple
    health_goal_ids = params[:health_goal_ids]&.reject(&:blank?)
    new_goal_names = params[:new_goal_names]&.reject(&:blank?)
    
    if health_goal_ids.blank? && new_goal_names.blank?
      flash[:alert] = "Please select at least one health goal to add."
      redirect_to new_user_health_goal_path
      return
    end
    
    goals_added = 0
    max_order = current_user.user_health_goals.maximum(:order_of_importance) || 0
    
    # First handle creating any new goals that don't exist
    if new_goal_names.present?
      new_goal_names.each_with_index do |goal_name, index|
        # Check if goal exists
        goal = HealthGoal.find_by(health_goal_name: HealthGoal.normalize_name(goal_name))
        if goal.nil?
          # Create a new goal
          goal = HealthGoal.create!(health_goal_name: goal_name)
        end
        
        # Add the goal to the user's list if it's not already there
        unless current_user.user_health_goals.exists?(health_goal_id: goal.id)
          current_user.user_health_goals.create!(
            health_goal_id: goal.id, 
            order_of_importance: max_order + goals_added + 1
          )
          goals_added += 1
        end
      end
    end
    
    # Then handle existing goals
    if health_goal_ids.present?
      # Get existing health_goal_ids to avoid duplicates
      existing_health_goal_ids = current_user.user_health_goals.pluck(:health_goal_id)
      new_health_goal_ids = health_goal_ids.map(&:to_i) - existing_health_goal_ids
      
      if new_health_goal_ids.any?
        records_to_insert = new_health_goal_ids.each_with_index.map do |health_goal_id, index|
          {
            user_id: current_user.id,
            health_goal_id: health_goal_id,
            order_of_importance: max_order + goals_added + index + 1,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
        
        # Use insert_all for better performance
        UserHealthGoal.insert_all(records_to_insert) if records_to_insert.any?
        goals_added += records_to_insert.size
      end
    end
    
    # Set success message and redirect
    if goals_added > 0
      flash[:notice] = "#{goals_added} #{goals_added == 1 ? 'health goal' : 'health goals'} successfully added."
    else
      flash[:alert] = "No new health goals were added to your list."
    end
    
    redirect_to user_health_goals_path
  end

  # These methods implement the required functionality for the MultipleSelection concern

  def resource_type
    :health_goal
  end

  def resource_path
    "user_health_goals"
  end

  def search_items_for_user(query)
    SearchService.search_health_goals(current_user, query)
  end

  def add_items_to_user(health_goal_ids)
    # Get maximum order of importance
    max_order = current_user.user_health_goals.maximum(:order_of_importance) || 0
    goals_added = 0

    # Handle new goal names if they exist
    new_goal_names = params[:new_goal_names]&.reject(&:blank?)
    if new_goal_names.present?
      new_goal_names.each_with_index do |goal_name, index|
        # Check if goal exists
        goal = HealthGoal.find_by(health_goal_name: HealthGoal.normalize_name(goal_name))
        if goal.nil?
          # Create a new goal
          goal = HealthGoal.create!(health_goal_name: goal_name)
        end

        # Add the goal to the user's list if it's not already there
        unless current_user.user_health_goals.exists?(health_goal_id: goal.id)
          current_user.user_health_goals.create!(
            health_goal_id: goal.id,
            order_of_importance: max_order + goals_added + 1
          )
          goals_added += 1
        end
      end
    end

    # Handle existing goal IDs
    if health_goal_ids.any?
      # Get existing health_goal_ids to avoid duplicates
      existing_health_goal_ids = current_user.user_health_goals.pluck(:health_goal_id)
      new_health_goal_ids = health_goal_ids.map(&:to_i) - existing_health_goal_ids

      # Batch create records for efficiency
      if new_health_goal_ids.any?
        records_to_insert = new_health_goal_ids.each_with_index.map do |health_goal_id, index|
          {
            user_id: current_user.id,
            health_goal_id: health_goal_id,
            order_of_importance: max_order + goals_added + index + 1,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        # Use insert_all for better performance
        UserHealthGoal.insert_all(records_to_insert) if records_to_insert.any?
        goals_added += records_to_insert.size
      end
    end

    goals_added
  end
  # Override the items_local_name to use the correct variable name in view templates
  def items_local_name
    "health_goals"
  end

  # Override the list_frame_id to use the correct frame ID
  def list_frame_id
    "health_goals_list"
  end

  # Override the current_user_items method to ensure proper ordering
  def current_user_items
    current_user.user_health_goals.ordered_by_importance
  end

  # Override empty selection handler to check for new goal names as well
  def handle_empty_selection
    # Check if we have new_goal_names even if item_ids is empty
    new_goal_names = params[:new_goal_names]&.reject(&:blank?)

    if new_goal_names.present?
      # We have new goal names, so proceed with adding them
      begin
        items_added = add_items_to_user([])
        success_message = "#{items_added} #{resource_type.to_s.humanize.downcase.pluralize(items_added)} successfully added."
        handle_successful_addition(success_message)
      rescue => e
        handle_error(e)
      end
    else
      # Use the default empty selection handler
      error_message = "Please select at least one #{resource_type.to_s.humanize.downcase}."
      respond_to do |format|
        format.turbo_stream do
          flash[:alert] = error_message
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages"
          )
        end
        format.html do
          redirect_to send("#{resource_path}_path"), alert: error_message
        end
      end
    end
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
