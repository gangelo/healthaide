class FoodsController < ApplicationController
  include Pager

  before_action :authenticate_admin!
  before_action :set_food, only: %i[ show edit update destroy ]

  # GET /foods or /foods.json
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

    set_pager_params

    respond_to do |format|
      format.html { redirect_to foods_path, status: :see_other, flash: { notice: "Food was successfully deleted." } }
      format.turbo_stream do
        flash.now[:notice] = "Food was successfully removed."
        turbo_stream_content = pagination_turbo_stream(records: @records, paginator: @pagy)
        turbo_stream_content << turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        render turbo_stream: turbo_stream_content
      end
    end
  end

  # Pager override
  def pager_rows_changed
    respond_to do |format|
      format.turbo_stream do
        turbo_stream_content = pagination_turbo_stream(records: @records, paginator: @pagy)
        render turbo_stream: turbo_stream_content
      end
      format.html { redirect_to foods_path }
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

  # Pager override
  def set_pager_pagination_path
    @pager_pagination_path = foods_path
  end

  # Pager override
  def set_pager_rows_changed_action_path
    @pager_rows_changed_action_path = pager_rows_changed_foods_path
  end

  # Pager override
  def pager_records_collection
    Food.ordered
  end

  def pagination_turbo_stream(records:, paginator:)
    [
      turbo_stream.update(
        "pager_results",
        partial: "foods/list/list",
        locals: { foods: @records }
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
