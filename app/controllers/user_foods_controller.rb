class UserFoodsController < ApplicationController
  include Pager

  before_action :authenticate_user!
  before_action :set_user_food, only: %i[ show edit update destroy ]

  # GET /user_foods or /user_foods.json
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

  # GET /user_foods/1 or /user_foods/1.json
  def show
  end

  # GET /user_foods/new
  def new
    @user_food = current_user.user_foods.new
    @user_food.build_food # Build a new food for the nested form
    @foods = Food.available_for(current_user)

    # Handle AJAX search requests
    if request.xhr? && params[:search].present?
      @foods = SearchService.search_foods(current_user, params[:search])
      render partial: "search_results", locals: { foods: @foods }
    end
  end

  # POST /user_foods or /user_foods.json
  def create
    @user_food = current_user.user_foods.new(user_food_params)

    # Set the user_id explicitly
    @user_food.user_id = current_user.id

    # Handle the case when food_id is provided (existing food)
    if params[:user_food][:food_id].present?
      @user_food.food_id = params[:user_food][:food_id]
      @user_food.food = nil # Don't create a new food in this case
    end

    # Handle case when food attributes are provided (new food)
    if params[:user_food][:food_attributes].present? && params[:user_food][:food_attributes][:food_name].present?
      food_name = params[:user_food][:food_attributes][:food_name]
      # Check if food already exists with normalized name
      existing_food = Food.find_by_food_name_normalized(food_name)

      if existing_food
        # Use existing food instead of creating new one
        @user_food.food = existing_food
      end
      # If food doesn't exist, the nested attributes will create it
    end

    if @user_food.save
      redirect_to user_foods_path, notice: "Food was successfully added to your list."
    else
      @foods = Food.available_for(current_user)
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    @user_food.errors.add(:base, e.record.errors.full_messages.to_sentence)
    @foods = Food.available_for(current_user)
    render :new, status: :unprocessable_entity
  end

  # DELETE /user_foods/1 or /user_foods/1.json
  def destroy
    @user_food.destroy

    set_pager_params

    respond_to do |format|
      format.html { redirect_to user_foods_path, notice: "Food was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Food was successfully removed."
        turbo_stream_content = pagination_turbo_stream(records: @records, paginator: @pagy)
        turbo_stream_content << turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        render turbo_stream: turbo_stream_content
      end
    end
  end

  def add_multiple
    food_ids = params[:food_ids]&.reject(&:blank?)
    new_food_names = params[:new_food_names]&.reject(&:blank?)

    if food_ids.blank? && new_food_names.blank?
      flash[:alert] = "Please select at least one food to add."
      redirect_to new_user_food_path
      return
    end

    foods_added = 0

    # First handle creating any new foods that don't exist
    if new_food_names.present?
      new_food_names.each do |food_name|
        # Build a new user_food with nested food attributes
        user_food = current_user.user_foods.new

        # Look for existing food with normalized name first
        food = Food.find_by_food_name_normalized(food_name)

        if food
          # Use existing food
          user_food.food = food
        else
          # Create new food through nested attributes
          user_food.build_food(food_name: food_name)
        end

        # Skip if the user already has this food
        next if user_food.food && current_user.user_foods.exists?(food_id: user_food.food.id)

        # Save with validation
        if user_food.save
          foods_added += 1
        end
      end
    end

    # Then handle existing foods - this part stays mostly the same
    if food_ids.present?
      # Process existing food IDs
      existing_food_ids = current_user.user_foods.pluck(:food_id)
      new_food_ids = food_ids.map(&:to_i) - existing_food_ids

      if new_food_ids.any?
        # Get available food IDs
        available_food_ids = Food.where(id: new_food_ids).pluck(:id)

        records_to_insert = available_food_ids.map do |food_id|
          { user_id: current_user.id, food_id: food_id, created_at: Time.current, updated_at: Time.current }
        end

        # Use insert_all for better performance
        UserFood.insert_all(records_to_insert) if records_to_insert.any?
        foods_added += records_to_insert.size
      end
    end

    # Set success message and redirect
    if foods_added > 0
      flash[:notice] = "#{foods_added} #{foods_added == 1 ? "food" : "foods"} successfully added."
    else
      flash[:alert] = "No new foods were added to your list."
    end

    redirect_to user_foods_path
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

  def set_user_food
    @user_food = current_user.user_foods.find(params[:id])
  end

  # Pager override
  def set_pager_pagination_path
    @pager_pagination_path = user_foods_path
  end

  # Pager override
  def set_pager_rows_changed_action_path
    @pager_rows_changed_action_path = pager_rows_changed_user_foods_path
  end

  # Pager override
  def pager_records_collection
    current_user.user_foods.ordered
  end

  def pagination_turbo_stream(records:, paginator:)
    [
      turbo_stream.update(
        "pager_results",
        partial: "user_foods/list/list",
        locals: { user_foods: @records }
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

  def food_params
    params.require(:food).permit(:food_name)
  end

  def user_food_params
    params.require(:user_food).permit(:food_id, food_attributes: [ :food_name ])
  end
end
