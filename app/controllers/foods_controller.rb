class FoodsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_food, only: %i[ show edit update destroy ]
  before_action :set_food_qualifiers, only: %i[ new edit create update ]

  # GET /foods or /foods.json
  def index
    @foods = Food.ordered.with_qualifiers
  end

  # GET /foods/1 or /foods/1.json
  def show
    @food_qualifiers = @food.food_qualifiers.ordered
  end

  # GET /foods/new
  def new
    @food = Food.new
    # Build associations for checkboxes that don't exist yet
    @food_qualifiers.each do |qualifier|
      @food.food_food_qualifiers.build(food_qualifier_id: qualifier.id)
    end
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
    # Build associations for checkboxes that don't exist yet
    @food_qualifiers.each do |qualifier|
      unless @food.food_food_qualifiers.exists?(food_qualifier_id: qualifier.id)
        @food.food_food_qualifiers.build(food_qualifier_id: qualifier.id)
      end
    end
  end

  # PATCH/PUT /foods/1 or /foods/1.json
  def update
    @food_qualifiers = FoodQualifier.ordered

    if @food.update(food_params)
      redirect_to @food, notice: "Food was successfully updated."
    else
      # Rebuild missing associations
      @food_qualifiers.each do |qualifier|
        unless @food.food_food_qualifiers.any? { |ffq| ffq.food_qualifier_id == qualifier.id }
          @food.food_food_qualifiers.build(food_qualifier_id: qualifier.id)
        end
      end
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

  def set_food_qualifiers
    @food_qualifiers = FoodQualifier.ordered
  end

  def food_params
    params.require(:food).permit(
      :food_name,
      food_food_qualifiers_attributes: [ :id, :food_qualifier_id, :_destroy ]
    )
  end
end
