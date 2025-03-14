class FoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_food, only: %i[ show edit update destroy add_qualifier remove_qualifier ]

  # GET /foods or /foods.json
  def index
    @foods = if params[:query].present?
      Food.kept.where("food_name ILIKE ?", "%#{params[:query]}%").order(:food_name).limit(10)
    else
      Food.kept.order(:food_name)
    end
  end

  # GET /foods/1 or /foods/1.json
  def show
    @food_qualifiers = @food.food_qualifiers.kept.ordered
    @available_qualifiers = FoodQualifier.kept.ordered.where.not(id: @food.food_qualifier_ids)
  end

  # GET /foods/new
  def new
    @food = Food.new
  end

  # GET /foods/1/edit
  def edit
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

  # PATCH/PUT /foods/1 or /foods/1.json
  def update
    respond_to do |format|
      if @food.update(food_params)
        format.html { redirect_to @food, notice: "Food was successfully updated." }
        format.json { render :show, status: :ok, location: @food }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /foods/1 or /foods/1.json
  def destroy
    @food.soft_delete

    respond_to do |format|
      format.html { redirect_to foods_path, status: :see_other, notice: "Food was successfully deleted." }
      format.json { head :no_content }
    end
  end

  # POST /foods/:id/add_qualifier
  def add_qualifier
    @qualifier = FoodQualifier.find(params[:qualifier_id])

    if @food.food_qualifiers.include?(@qualifier)
      message = "#{@qualifier.qualifier_name} is already associated with this food."
      flash[:notice] = message
    else
      @food.food_qualifiers << @qualifier
      message = "Added #{@qualifier.qualifier_name} to #{@food.food_name}."
      flash[:success] = message
    end

    @available_qualifiers = FoodQualifier.kept.where.not(id: @food.food_qualifier_ids)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("qualifier-list", partial: "foods/qualifier_list", locals: { food: @food }),
          turbo_stream.replace("add_existing_qualifier", partial: "foods/add_existing_qualifier_form", locals: { food: @food, available_qualifiers: @available_qualifiers }),
          turbo_stream.replace("flash", partial: "shared/flash")
        ]
      end
      format.html { redirect_to @food }
    end
  end

  # DELETE /foods/:id/remove_qualifier
  def remove_qualifier
    @qualifier = FoodQualifier.find(params[:qualifier_id])

    if @food.food_qualifiers.include?(@qualifier)
      @food.food_qualifiers.delete(@qualifier)
      message = "Removed #{@qualifier.qualifier_name} from #{@food.food_name}."
      flash[:success] = message
    else
      message = "#{@qualifier.qualifier_name} is not associated with this food."
      flash[:notice] = message
    end

    @available_qualifiers = FoodQualifier.kept.where.not(id: @food.food_qualifier_ids)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("qualifier-list", partial: "foods/qualifier_list", locals: { food: @food }),
          turbo_stream.replace("add_existing_qualifier", partial: "foods/add_existing_qualifier_form", locals: { food: @food, available_qualifiers: @available_qualifiers }),
          turbo_stream.replace("flash", partial: "shared/flash")
        ]
      end
      format.html { redirect_to @food }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_food
      @food = Food.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def food_params
      params.require(:food).permit(:food_name)
    end
end
