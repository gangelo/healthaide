class UserMealPromptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_meal_prompt
  before_action :set_wizard_variables, only: [ :wizard, :step_1, :step_2, :step_3, :step_4 ]

  # GET /user_meal_prompts/:id
  def show
  end

  # PATCH/PUT /user_meal_prompts/:id
  def update
    if @user_meal_prompt.update(user_meal_prompt_params)
      redirect_to user_meal_prompt_path(@user_meal_prompt), notice: "Meal prompt was successfully updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  # DELETE /user_meal_prompts/:id
  def destroy
    @user_meal_prompt.destroy
    redirect_to root_path, notice: "Meal prompt was successfully deleted."
  end

  # Wizard steps

  # GET /user_meal_prompts/wizard
  def wizard
    # Create or find the meal prompt for this user
    redirect_to step_1_user_meal_prompts_path
  end

  # GET /user_meal_prompts/step_1
  def step_1
    # Food selection step
  end

  # GET /user_meal_prompts/step_2
  def step_2
    # Health conditions step
  end

  # GET /user_meal_prompts/step_3
  def step_3
    # Health goals step
  end

  # GET /user_meal_prompts/step_4
  def step_4
    # User stats and supplements step
  end

  # POST /user_meal_prompts/update_step
  def update_step
    # Save form data directly to database
    user_meal_prompt_data = params[:user_meal_prompt] || {}

    # Handle arrays
    [ :food_ids, :health_condition_ids, :health_goal_ids, :user_supplement_ids ].each do |array_key|
      @user_meal_prompt[array_key] = Array(user_meal_prompt_data[array_key].presence).map(&:to_i)
    end

    # Handle boolean and numeric values
    @user_meal_prompt.include_user_stats = user_meal_prompt_data[:include_user_stats] == "1" if user_meal_prompt_data.key?(:include_user_stats)
    @user_meal_prompt.meals_count = user_meal_prompt_data[:meals_count].to_i if user_meal_prompt_data[:meals_count].present?

    @user_meal_prompt.save

    # Handle back button navigation
    if params[:direction] == "back" && params[:current_step].present?
      current_step = params[:current_step].to_i
      prev_step = current_step - 1

      if prev_step >= 1
        return case prev_step
               when 1
                 redirect_to step_1_user_meal_prompts_path
               when 2
                 redirect_to step_2_user_meal_prompts_path
               when 3
                 redirect_to step_3_user_meal_prompts_path
               else
                 redirect_to step_1_user_meal_prompts_path
               end
      end
    end

    # Determine next step or finalize
    next_step = params[:next_step]

    if next_step == "finalize"
      @user_meal_prompt.update(generated_at: Time.current)
      redirect_to user_meal_prompt_path(@user_meal_prompt), notice: "Meal prompt generated successfully."
      return
    end

    # Otherwise redirect to the next step
    # Make sure next_step is a valid step number
    case next_step.to_i
    when 1
      redirect_to step_1_user_meal_prompts_path, notice: "Meal prompt updated successfully."
    when 2
      redirect_to step_2_user_meal_prompts_path, notice: "Meal prompt updated successfully."
    when 3
      redirect_to step_3_user_meal_prompts_path, notice: "Meal prompt updated successfully."
    when 4
      redirect_to step_4_user_meal_prompts_path, notice: "Meal prompt updated successfully."
    else
      # Default to step 1 if invalid step
      redirect_to step_1_user_meal_prompts_path, notice: "Meal prompt updated successfully."
    end
  end

  # POST /user_meal_prompts/generate
  def generate
    @user_meal_prompt.update(generated_at: Time.current)
    redirect_to user_meal_prompt_path(@user_meal_prompt), notice: "Meal prompt generated successfully."
  end

  private

  def set_user_meal_prompt
    @user_meal_prompt = UserMealPrompt.find_or_create_by(user: current_user)

    # Redirect to wizard if no meal prompt exists
    redirect_to wizard_user_meal_prompts_path if @user_meal_prompt.nil?
  end

  def set_wizard_variables
    @available_foods   = current_user.user_foods.ordered
    @health_conditions = current_user.user_health_conditions.ordered
    @health_goals      = current_user.user_health_goals.ordered_by_importance
    @user_stat         = current_user.user_stat
    @user_supplements       = current_user.user_supplements.ordered
  end

  def user_meal_prompt_params
    params.require(:user_meal_prompt).permit(
      :include_user_stats,
      :meals_count,
      { food_ids: [] },
      { health_condition_ids: [] },
      { health_goal_ids: [] },
      { user_supplement_ids: [] }
    )
  end
end
