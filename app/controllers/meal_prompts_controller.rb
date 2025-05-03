class MealPromptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meal_prompt
  before_action :set_wizard_variables, only: [ :wizard, :step_1, :step_2, :step_3, :step_4 ]

  # GET /meal_prompts/:id
  def show
  end

  # PATCH/PUT /meal_prompts/:id
  def update
    if @meal_prompt.update(meal_prompt_params)
      redirect_to meal_prompt_path(@meal_prompt), notice: "Meal prompt was successfully updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  # DELETE /meal_prompts/:id
  def destroy
    @meal_prompt.destroy
    redirect_to root_path, notice: "Meal prompt was successfully deleted."
  end

  # Wizard steps

  # GET /meal_prompts/wizard
  def wizard
    # Create or find the meal prompt for this user
    redirect_to step_1_meal_prompts_path
  end

  # GET /meal_prompts/step_1
  def step_1
    # Food selection step
  end

  # GET /meal_prompts/step_2
  def step_2
    # Health conditions step
  end

  # GET /meal_prompts/step_3
  def step_3
    # Health goals step
  end

  # GET /meal_prompts/step_4
  def step_4
    # User stats and supplements step
  end

  # POST /meal_prompts/update_step
  def update_step
    Rails.logger.debug "MealPromptsController params: #{params.inspect}"

    # Save form data directly to database
    meal_prompt_data = params[:meal_prompt] || {}

    # Handle arrays
    [ :food_ids, :health_condition_ids, :health_goal_ids, :supplement_ids ].each do |array_key|
      @meal_prompt[array_key] = Array(meal_prompt_data[array_key].presence).map(&:to_i)
    end

    # Handle boolean and numeric values
    @meal_prompt.include_user_stats = meal_prompt_data[:include_user_stats] == "1" if meal_prompt_data.key?(:include_user_stats)
    @meal_prompt.meals_count = meal_prompt_data[:meals_count].to_i if meal_prompt_data[:meals_count].present?

    @meal_prompt.save

    # Determine next step or finalize
    next_step = params[:next_step]

    if next_step == "finalize"
      redirect_to meal_prompt_path(@meal_prompt), notice: "Meal prompt created successfully."
      return
    end

    # Handle back button navigation
    if params[:direction] == "back" && params[:current_step].present?
      current_step = params[:current_step].to_i
      prev_step = current_step - 1

      if prev_step >= 1
        redirect_to send("step_#{prev_step}_meal_prompts_path")
        return
      end
    end

    Rails.logger.debug "MealPromptsController next_step: #{next_step}"


    # Otherwise redirect to the next step
    # Make sure next_step is a valid step number
    redirect_path = if next_step.to_i.between?(1, 4)
      send("step_#{next_step}_meal_prompts_path")
    else
      # Default to step 1 if invalid step
      step_1_meal_prompts_path
    end

    Rails.logger.debug "MealPromptsController redirect_path: #{redirect_path}"

    redirect_to redirect_path, notice: "Meal prompt updated successfully."
  end

  # POST /meal_prompts/generate
  def generate
    @meal_prompt.update(generated_at: Time.current)
    redirect_to meal_prompt_path(@meal_prompt), notice: "Meal plan generated successfully."
  end

  private

  def set_meal_prompt
    @meal_prompt = MealPrompt.find_or_create_by(user: current_user)

    # Redirect to wizard if no meal prompt exists
    redirect_to wizard_meal_prompts_path if @meal_prompt.nil?
  end

  def set_wizard_variables
    @available_foods   = current_user.user_foods.available.ordered
    @health_conditions = current_user.user_health_conditions.ordered
    @health_goals      = current_user.user_health_goals.ordered_by_importance
    @user_stat         = current_user.user_stat
    @supplements       = current_user.user_supplements.ordered
  end

  def meal_prompt_params
    params.require(:meal_prompt).permit(
      :include_user_stats,
      :meals_count,
      { food_ids: [] },
      { health_condition_ids: [] },
      { health_goal_ids: [] },
      { supplement_ids: [] }
    )
  end
end
