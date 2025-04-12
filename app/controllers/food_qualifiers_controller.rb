class FoodQualifiersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_food_qualifier, only: %i[ show edit update destroy ]
  before_action :set_food_qualifiers, only: %i[ index ]

  # GET /food_qualifiers or /food_qualifiers.json
  def index
  end

  # GET /food_qualifiers/1 or /food_qualifiers/1.json
  def show
    @foods = @food_qualifier.foods.kept
  end

  # GET /food_qualifiers/new
  def new
    @food_qualifier = FoodQualifier.new
  end

  # GET /food_qualifiers/1/edit
  def edit
  end

  # POST /food_qualifiers or /food_qualifiers.json
  def create
    @food_qualifier = FoodQualifier.new(food_qualifier_params)

    respond_to do |format|
      if @food_qualifier.save
        format.html { redirect_to @food_qualifier, notice: "Food qualifier was successfully created." }
        format.json { render :show, status: :created, location: @food_qualifier }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @food_qualifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /food_qualifiers/1 or /food_qualifiers/1.json
  def update
    respond_to do |format|
      if @food_qualifier.update(food_qualifier_params)
        format.html { redirect_to @food_qualifier, notice: "Food qualifier was successfully updated." }
        format.json { render :show, status: :ok, location: @food_qualifier }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food_qualifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /food_qualifiers/1 or /food_qualifiers/1.json
  def destroy
    if @food_qualifier.destroy
      set_food_qualifiers

      respond_to do |format|
        format.turbo_stream do
          flash[:notice] = "Food qualifier was successfully deleted."
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "shared/flash_messages"),
            turbo_stream.replace("main_content",
              partial: "food_qualifiers/list/list",
              locals: { food_qualifiers: @food_qualifiers })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash[:alert] = @food_qualifier.errors.full_messages.to_sentence
          render turbo_stream: turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        end
      end
    end
  end

  # POST /food_qualifiers/find_or_create
  def find_or_create
    name = params[:qualifier_name].to_s.strip
    @food_qualifier = FoodQualifier.kept.find_by("LOWER(qualifier_name) = ?", name.downcase)

    if @food_qualifier.nil? && name.present?
      @food_qualifier = FoodQualifier.create(qualifier_name: name)
    end

    if @food_qualifier&.persisted? && params[:food_id].present?
      # We're adding a qualifier to a food
      @food = Food.kept.find(params[:food_id])

      if @food.includes_qualifier?(@food_qualifier)
        # Qualifier is already associated with this food
        flash[:notice] = "#{@food_qualifier.qualifier_name} is already associated with this food."
      else
        # Add the qualifier to the food
        @food.food_qualifiers << @food_qualifier
        flash[:success] = "Added #{@food_qualifier.qualifier_name} to #{@food.food_name}."
      end

      @available_qualifiers = FoodQualifier.kept.where.not(id: @food.food_qualifier_ids)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("qualifier-list", partial: "foods/qualifier_list", locals: { food: @food }),
            turbo_stream.replace("add_existing_qualifier", partial: "foods/add_existing_qualifier_form", locals: { food: @food, available_qualifiers: @available_qualifiers }),
            turbo_stream.replace("flash_messages", partial: "shared/flash_messages")
          ]
        end
        format.html { redirect_to @food }
      end
    elsif @food_qualifier&.persisted?
      # Just created a food qualifier outside of a food context
      respond_to do |format|
        format.html { redirect_to @food_qualifier, notice: "Food qualifier was successfully created." }
        format.json { render json: @food_qualifier }
      end
    else
      # Could not find or create qualifier
      error_message = "Could not find or create qualifier"
      respond_to do |format|
        format.html {
          flash[:error] = error_message
          redirect_back(fallback_location: root_path)
        }
        format.json { render json: { error: error_message }, status: :unprocessable_entity }
      end
    end
  end

  # GET /food_qualifiers/export
  def export
    respond_to do |format|
      format.html {
        render html: FoodQualifierExportService.export
      }
      format.json {
        send_data JSON.pretty_generate(FoodQualifierExportService.export), filename: "food_qualifiers.json"
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_food_qualifier
    @food_qualifier = FoodQualifier.find(params[:id])
  end

  def set_food_qualifiers
    @food_qualifiers = FoodQualifier.kept.order(:qualifier_name)
  end

  # Only allow a list of trusted parameters through.
  def food_qualifier_params
    params.require(:food_qualifier).permit(:qualifier_name)
  end
end
