class UserFoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_food, only: %i[ show edit update destroy ]

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
    # Find or create the food
    food_name = user_food_params[:food_name]
    food = Food.find_by(food_name: food_name)

    if food.nil? && food_name.present?
      food = Food.create(food_name: food_name)
    end

    @user_food = current_user.user_foods.new(favorite: user_food_params[:favorite])
    @user_food.food = food if food

    respond_to do |format|
      if @user_food.save
        format.html { redirect_to @user_food, notice: "Food was successfully added to your list." }
        format.json { render :show, status: :created, location: @user_food }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_food.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_foods/1 or /user_foods/1.json
  def update
    respond_to do |format|
      if @user_food.update(user_food_params.except(:food_name))
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_food
      @user_food = current_user.user_foods.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_food_params
      params.require(:user_food).permit(:favorite, :food_name)
    end
end
