class FoodsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_food, only: %i[ show edit update destroy ]

  # GET /foods or /foods.json
  def index
    @foods = Food.ordered
  end

  # GET /foods/1 or /foods/1.json
  def show
  end

  # GET /foods/new
  def new
    @food = Food.new
  end

  # POST /foods or /foods.json
  def create
    @food = Food.new(food_params)

    respond_to do |format|
      if @food.save
        format.html { redirect_to @food, notice: "Food was successfully created." }
        format.json { render :show, status: :created, location: @food }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @food.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /foods/1/edit
  def edit
  end

  # PATCH/PUT /foods/1 or /foods/1.json
  def update
    if @food.update(food_params)
      redirect_to @food, notice: "Food was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /foods/1 or /foods/1.json
  def destroy
    @food.destroy
    @foods = Food.ordered

    respond_to do |format|
      format.html { redirect_to foods_path, status: :see_other, flash: { notice: "Food was successfully deleted." } }
      format.turbo_stream do
        flash.now[:notice] = "Food was successfully deleted."
        render turbo_stream: [
          turbo_stream.update("main_content",
            partial: "foods/list/list",
            locals: { foods: @foods }),
          turbo_stream.update("flash_messages",
            partial: "shared/flash_messages")
        ]
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_food
    @food = Food.find(params[:id])
  end

  def food_params
    params.require(:food).permit(:food_name)
  end
end
