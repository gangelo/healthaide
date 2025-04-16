class UserFoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_food, only: %i[ show edit update destroy ]
  before_action :set_user_foods, only: [ :index ]

  # GET /user_foods or /user_foods.json
  def index
  end

  # GET /user_foods/1 or /user_foods/1.json
  def show
  end

  # GET /user_foods/new
  def new
    @user_food = current_user.user_foods.new
    @user_food.build_food # Build a new food for the nested form
    @foods = Food.available_for(current_user, include_qualifiers: true)

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

  # GET /user_foods/1/edit
  def edit
  end

  # PATCH/PUT /user_foods/1 or /user_foods/1.json
  def update
    respond_to do |format|
      if @user_food.update(user_food_params)
        format.html { redirect_to @user_food, notice: "Food item was successfully updated." }
        format.json { render :show, status: :ok, location: @user_food }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_food.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_foods/1 or /user_foods/1.json
  def destroy
    @user_food.destroy
    set_user_foods

    respond_to do |format|
      format.html { redirect_to user_foods_path, notice: "Food was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Food was successfully removed."
        render turbo_stream: [
          turbo_stream.update("main_content",
            partial: "user_foods/list/list",
            locals: { user_foods: @user_foods }),
          turbo_stream.update("flash_messages",
            partial: "shared/flash_messages")
        ]
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_food
    @user_food = current_user.user_foods.find(params[:id])
  end

  def set_user_foods
    @user_foods = current_user.user_foods.includes(:food).ordered
  end

  def food_params
    params.require(:food).permit(
      :food_name,
      food_food_qualifiers_attributes: [ :id, :food_qualifier_id, :_destroy ]
    )
  end
end
