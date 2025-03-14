class UserFoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_food, only: %i[ show edit update destroy add_qualifier ]

  # GET /user_foods or /user_foods.json
  def index
    @user_foods = current_user.user_foods.kept.includes(:food)
  end

  # GET /user_foods/1 or /user_foods/1.json
  def show
  end

  # GET /user_foods/new
  def new
    @user_food = current_user.user_foods.new
  end

  # GET /user_foods/1/edit
  def edit
  end

  # POST /user_foods or /user_foods.json
  def create
    @user_food = current_user.user_foods.new

    if params[:user_food][:food_id].present?
      # Using existing food
      @user_food.food_id = params[:user_food][:food_id]
    elsif params[:user_food][:new_food_name].present?
      # Create new food
      food = Food.create!(food_name: params[:user_food][:new_food_name])
      @user_food.food = food
    else
      # Neither option selected
      @user_food.errors.add(:base, "Please select an existing food or enter a new food name")
      render :new, status: :unprocessable_entity
      return
    end

    if @user_food.save
      redirect_to user_foods_path, notice: "Food was successfully added to your list."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    @user_food.errors.add(:base, e.record.errors.full_messages.to_sentence)
    render :new, status: :unprocessable_entity
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
    @user_food.soft_delete

    respond_to do |format|
      format.html { redirect_to user_foods_path, status: :see_other, notice: "Food was successfully removed from your list." }
      format.json { head :no_content }
    end
  end

  def add_qualifier
    if params[:food_qualifier_id].present?
      qualifier = FoodQualifier.find(params[:food_qualifier_id])
      @user_food.food.food_qualifiers << qualifier unless @user_food.food.food_qualifiers.include?(qualifier)
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

  def add_multiple
    food_ids = params[:food_ids]

    if food_ids.blank?
      redirect_to new_user_food_path, alert: "Please select at least one food"
      return
    end

    created_foods = food_ids.map do |food_id|
      current_user.user_foods.create(food_id: food_id)
    end

    if created_foods.all?(&:persisted?)
      redirect_to user_foods_path, notice: "#{created_foods.count} foods were successfully added"
    else
      redirect_to new_user_food_path, alert: "There was an error adding some foods"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_food
      @user_food = current_user.user_foods.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_food_params
      params.require(:user_food).permit(:food_id, :new_food_name)
    end
end
