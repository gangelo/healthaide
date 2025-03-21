class UserFoodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_food, only: %i[ show edit update destroy add_qualifier ]

  # GET /user_foods or /user_foods.json
  def index
    @user_foods = current_user.user_foods.kept.includes(:food).ordered
  end

  # GET /user_foods/1 or /user_foods/1.json
  def show
  end

  # GET /user_foods/new
  def new
    @user_food = current_user.user_foods.new
    @foods = Food.not_selected_by(current_user)
  end

  # POST /user_foods or /user_foods.json
  def create
    @user_food = current_user.user_foods.new

    if params[:user_food][:food_id].blank?
      @user_food.errors.add(:base, "Please select an existing food or enter a new food name")
      @foods = Food.not_selected_by(current_user)
      render :new, status: :unprocessable_entity

      return
    end

    if params[:user_food][:food_id].present?
      # Using existing food
      @user_food.food_id = params[:user_food][:food_id]
    elsif params[:user_food][:new_food_name].present?
      # Undelete the food if it was soft-deleted
      food = Food.discarded.find_by(food_name: params[:user_food][:new_food_name])&.first
      unless food.present?
        Food.create!(food_name: params[:user_food][:new_food_name])
      end
      @user_food.food = food
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

  def select_multiple
    # Get the list of foods not already selected by the user
    # Use a more efficient query that doesn't require pluck
    user_food_ids = current_user.user_foods.select(:food_id)
    base_query = Food.ordered.where.not(id: user_food_ids)

    # Include food qualifiers for better display
    @foods = base_query.includes(:food_qualifiers)

    # Ensure consistent search behavior
    search_param = params[:search].to_s.strip.presence
    if search_param
      search_term = "%#{search_param.downcase}%"
      @foods = @foods.where("LOWER(food_name) LIKE ?", search_term)
    end

    respond_to do |format|
      format.html do
        if turbo_frame_request? && params[:_frame] == "foods_list"
          # Render just the foods list within its turbo frame
          render :_foods_list_frame, locals: { foods: @foods }
        elsif turbo_frame_request?
          # For the entire modal
          render partial: "multiple_foods_modal", locals: { foods: @foods }
        end
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "foods_list",
          partial: "user_foods/foods_list",
          locals: { foods: @foods }
        )
      end
    end
  end

  def add_multiple
    food_ids = params[:food_ids]&.reject(&:blank?)

    if food_ids.blank?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { alert: "Please select at least one food." }
          )
        end
        format.html do
          redirect_to user_foods_path, alert: "Please select at least one food."
        end
      end
      return
    end

    begin
      # Use bulk insert for efficiency
      foods_added = 0

      # Get existing food_ids to avoid duplicates
      existing_food_ids = current_user.user_foods.pluck(:food_id)
      new_food_ids = food_ids.map(&:to_i) - existing_food_ids

      # Batch create records for efficiency
      if new_food_ids.any?
        records_to_insert = new_food_ids.map do |food_id|
          { user_id: current_user.id, food_id: food_id, created_at: Time.current, updated_at: Time.current }
        end

        # Use insert_all for better performance
        UserFood.insert_all(records_to_insert)
        foods_added = new_food_ids.size
      end

      message = "#{foods_added} #{"food".pluralize(foods_added)} successfully added."

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "user_foods_list",
              partial: "user_foods_list",
              locals: { user_foods: current_user.user_foods.includes(:food).ordered }
            ),
            turbo_stream.update(
              "flash_messages",
              partial: "shared/flash_messages",
              locals: { notice: message }
            ),
            turbo_stream.replace(
              "modal",
              partial: "shared/empty_frame"
            )
          ]
        end
        format.html do
          redirect_to user_foods_path, notice: message
        end
      end
    rescue => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash_messages",
            partial: "shared/flash_messages",
            locals: { alert: "Error adding foods: #{e.message}" }
          )
        end
        format.html do
          redirect_to user_foods_path, alert: "Error adding foods: #{e.message}"
        end
      end
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
