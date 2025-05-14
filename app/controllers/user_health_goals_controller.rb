class UserHealthGoalsController < ApplicationController
  include Pager

  before_action :authenticate_user!
  before_action :set_user_health_goal, only: [ :show, :edit, :update, :destroy ]

  def index
    debug_show_pager_params do
      "#{self.class.name}#index:"
    end
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: pagination_turbo_stream(records: @records, paginator: @pagy)
      end
    end
  end

  def show
  end

  def new
    @user_health_goal = current_user.user_health_goals.build

    # Get all health goals not already associated with the user
    user_goal_ids = current_user.health_goals.pluck(:id)
    @health_goals = HealthGoal.ordered.where.not(id: user_goal_ids)

    # Handle AJAX search requests
    if request.xhr? && params[:search].present?
      @health_goals = SearchService.search_health_goals(current_user, params[:search])
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

    set_pager_params

    respond_to do |format|
      format.html { redirect_to user_health_goals_path, notice: "Health goal was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Health goal was successfully removed."
        turbo_stream_content = pagination_turbo_stream(records: @records, paginator: @pagy)
        turbo_stream_content << turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        render turbo_stream: turbo_stream_content
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
      flash[:notice] = "#{goals_added} #{goals_added == 1 ? "health goal" : "health goals"} successfully added."
    else
      flash[:alert] = "No new health goals were added to your list."
    end

    redirect_to user_health_goals_path
  end

  # Pager override
  def pager_rows_changed
    respond_to do |format|
      format.turbo_stream do
        turbo_stream_content = pagination_turbo_stream(records: @records, paginator: @pagy)
        render turbo_stream: turbo_stream_content
      end
      format.html { redirect_to user_foods_path }
    end
  end

  private

  def set_user_health_goal
    @user_health_goal = current_user.user_health_goals.find(params[:id])
  end

  def health_goal_params
    params.require(:user_health_goal).permit(:health_goal_id, :health_goal_name, :order_of_importance)
  end

  # Pager override
  def set_pager_pagination_path
    @pager_pagination_path = user_health_goals_path
  end

  # Pager override
  def set_pager_rows_changed_action_path
    @pager_rows_changed_action_path = pager_rows_changed_user_health_goals_path
  end

  # Pager override
  def pager_records_collection
    current_user.user_health_goals.ordered_by_importance
  end

  def pagination_turbo_stream(records:, paginator:)
    [
      turbo_stream.update(
        "pager_results",
        partial: "user_health_goals/list/list",
        locals: { user_health_goals: @records }
      ),
      turbo_stream.update(
        "pagination_controls",
        partial: "shared/pager",
        locals: {
          pager_pagination_path: @pager_pagination_path,
          pagy: @pagy,
          pager_rows: @pager_rows
        }
      )
    ]
  end
end
