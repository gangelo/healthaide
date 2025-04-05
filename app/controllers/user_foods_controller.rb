class UserFoodsController < ApplicationController
  include MultipleSelection

  before_action :authenticate_user!
  before_action :set_user_food, only: %i[ show edit update destroy add_qualifier ]
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
    @foods = Food.available_for(current_user, include_qualifiers: true)
  end

  # POST /user_foods or /user_foods.json
  def create
    @user_food = current_user.user_foods.new

    new_food_name = params[:user_food][:new_food_name]
    food_id = params[:user_food][:food_id]

    if food_id.blank? && new_food_name.blank?
      @user_food.errors.add(:base, "Please select an existing food or enter a new food name")
      @foods = Food.available_for(current_user)
      render :new, status: :unprocessable_entity

      return
    end

    # From Create & Add New Food
    @user_food.food = if new_food_name.present?
      food = Food.find_by_food_name_normalized(new_food_name)
      if food&.discarded?
        food.restore
        flash[:notice] = "Existing food '#{new_food_name}' was restored."
      end
      food = Food.create!(food_name: new_food_name) if food.nil?
      food
    else
      # From Select Existing Food
      Food.kept.find(food_id)
    end

    if @user_food.save
      @foods = Food.available_for(current_user)
      redirect_to user_foods_path, notice: "Food was successfully added to your list."
    else
      @foods = Food.available_for(current_user)
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    @user_food.errors.add(:base, e.record.errors.full_messages.to_sentence)
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

  def add_qualifier
    if params[:food_qualifier_id].present?
      qualifier = FoodQualifier.find(params[:food_qualifier_id])
      @user_food.food.food_qualifiers << qualifier unless @user_food.food.includes_qualifier?(qualifier)
      redirect_to @user_food, notice: "Qualifier was successfully added."
    elsif params[:new_qualifier_name].present?
      qualifier = FoodQualifier.create!(qualifier_name: params[:new_qualifier_name])
      @user_food.food.food_qualifiers << qualifier
      redirect_to @user_food, notice: "New qualifier was successfully created and added."
    else
      redirect_to @user_food, alert: "Please select an existing qualifier or enter a new one."
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @user_food, alert: e.record.errors.full_messages.to_sentence
  end

  # These methods provide the required implementation for the MultipleSelection concern
  private

  def resource_type
    :food
  end

  def resource_path
    "user_foods"
  end

  def search_items_for_user(query)
    SearchService.search_foods(current_user, query)
  end

  def add_items_to_user(food_ids)
    # Use bulk insert for efficiency
    foods_added = 0

    # Get existing food_ids to avoid duplicates
    existing_food_ids = current_user.user_foods.pluck(:food_id)
    new_food_ids = food_ids.map(&:to_i) - existing_food_ids

    # Batch create records for efficiency
    if new_food_ids.any?
      # Filter out any soft-deleted foods
      available_food_ids = Food.where(id: new_food_ids).kept.pluck(:id)

      records_to_insert = available_food_ids.map do |food_id|
        { user_id: current_user.id, food_id: food_id, created_at: Time.current, updated_at: Time.current }
      end

      # Use insert_all for better performance
      UserFood.insert_all(records_to_insert) if records_to_insert.any?
      foods_added = records_to_insert.size
    end

    foods_added
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_food
    @user_food = current_user.user_foods.find(params[:id])
  end

  def set_user_foods
    @user_foods = current_user.user_foods.includes(:food).ordered
  end

  # Only allow a list of trusted parameters through.
  def user_food_params
    params.require(:user_food).permit(:food_id, :new_food_name)
  end
end
