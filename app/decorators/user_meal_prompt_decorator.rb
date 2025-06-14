class UserMealPromptDecorator < BaseDecorator
  def formatted_foods_section
    return "[No foods selected]" if foods.empty?

    foods.map { |food| "- #{food.food_name}" }.join("\n")
  end

  def formatted_health_profile
    return "" unless include_user_stats? && user.user_stat.present?

    health_conditions_line = if health_conditions.any?
      "- Conditions: #{health_conditions.map(&:health_condition_name).join(", ")}"
    else
      ""
    end

    <<~HEALTH_PROFILE
      MY HEALTH PROFILE:
      - #{formatted_user_stats}
      #{health_conditions_line unless health_conditions_line.empty?}
    HEALTH_PROFILE
  end

  def formatted_user_stats
    user_stat = user.user_stat
    return "" unless user_stat

    stats = []

    # Basic demographics
    stats << (user_stat.sex == "M" ? "Male" : "Female") if user_stat.sex?
    stats << calculate_age if user_stat.birthday?
    stats << formatted_height if user_stat.height?

    # Weight and body composition
    stats << "#{user_stat.muscle_fat_analysis_weight} lbs" if user_stat.muscle_fat_analysis_weight?
    stats << "BMI: #{user_stat.obesity_analysis_bmi}" if user_stat.obesity_analysis_bmi?
    stats << "#{user_stat.obesity_analysis_percent_body_fat}% body fat" if user_stat.obesity_analysis_percent_body_fat?

    # Additional measurements if available
    stats << "#{user_stat.muscle_fat_analysis_skeletal_muscle_mass} lbs muscle mass" if user_stat.muscle_fat_analysis_skeletal_muscle_mass?
    stats << "#{user_stat.muscle_fat_analysis_body_fat_mass} lbs fat mass" if user_stat.muscle_fat_analysis_body_fat_mass?
    stats << "Waist hip ratio: #{user_stat.abdominal_obesity_analysis_waist_hip_ratio}" if user_stat.abdominal_obesity_analysis_waist_hip_ratio?
    stats << "Visceral fat level: #{user_stat.abdominal_obesity_analysis_visceral_fat_level}" if user_stat.abdominal_obesity_analysis_visceral_fat_level?
    stats << "Basal metabolic rate (BMR): #{user_stat.comprehensive_analysis_basal_metabolic_rate} (kJ)" if user_stat.comprehensive_analysis_basal_metabolic_rate?
    stats << "Soft lean mass: #{user_stat.body_composition_analysis_soft_lean_mass} lbs" if user_stat.body_composition_analysis_soft_lean_mass?

    stats.join(", ")
  end

  def formatted_supplements
    return "" if user_supplements.empty?

    supplements_content = user_supplements.map do |user_supplement|
      "- #{format_supplement(user_supplement)}"
    end.join("\n")

    <<~SUPPLEMENTS
      SUPPLEMENTS:
      #{supplements_content}
    SUPPLEMENTS
  end

  def format_supplement(user_supplement)
    if user_supplement.supplement_components.any?
      components = user_supplement.supplement_components.map do |sc|
        "#{sc.supplement_component_name} #{sc.amount} #{sc.unit}"
      end.join(", ")

      "#{user_supplement.user_supplement_name} (#{components})"
    elsif user_supplement.dosage?
      "#{user_supplement.user_supplement_name}, #{user_supplement.dosage} #{user_supplement.dosage_unit}, #{user_supplement.frequency.to_s.humanize.downcase}"
    else
      "#{user_supplement.user_supplement_name}, #{user_supplement.frequency.to_s.humanize.downcase}"
    end
  end

  def formatted_health_goals
    if health_goals.empty?
      <<~EMPTY_GOALS
        HEALTH PRIORITIES (MUST ADDRESS THESE, IN ORDER OF IMPORTANCE):
        [No health goals selected]
      EMPTY_GOALS
    else
      goals_content = health_goals.each_with_index.map do |goal, index|
        user_health_goal = user.user_health_goals.find_by(health_goal_id: goal.id)
        "#{user_health_goal.order_of_importance}. #{goal.health_goal_name}"
      end.join("\n")

      <<~GOALS
        HEALTH PRIORITIES (MUST ADDRESS THESE, IN ORDER OF IMPORTANCE):
        #{goals_content}
      GOALS
    end
  end

  def formatted_instructions
    <<~INSTRUCTIONS
      PROVIDE [#{meals_count}] #{pluralize_meals_count} WITH:
      - Specific portions (oz/cups), DO NOT PROVIDE RECIPES!!!
      - Which foods to use (#{formatted_food_examples}).
      - EXPLAIN HOW each meal directly supports my health conditions and priorities
    INSTRUCTIONS
  end

  def formatted_food_examples
    sample_foods = foods.take(3).map(&:food_name).join(", ")
    foods.count > 3 ? "#{sample_foods}, etc." : sample_foods
  end

  def pluralize_meals_count
    "MEAL".pluralize(meals_count).upcase
  end

  def full_formatted_prompt
    sections = [ "CREATE A MEAL PLAN USING MY AVAILABLE FOODS THAT SPECIFICALLY SUPPORTS MY HEALTH NEEDS:" ]

    sections << "\nAVAILABLE FOODS:"
    sections << formatted_foods_section

    if include_user_stats?
      sections << "\n" + formatted_health_profile.strip
    end

    if user_supplements.any?
      sections << "\n" + formatted_supplements.strip
    end

    sections << "\n" + formatted_health_goals.strip
    sections << "\n" + formatted_instructions.strip

    sections.join("\n")
  end

  private

  def calculate_age
    return "N/A" unless user.user_stat&.birthday
    ((Date.today - user.user_stat.birthday) / 365.25).to_i
  end

  def formatted_height
    return "N/A" unless user.user_stat&.height
    feet = user.user_stat.height / 12
    inches = user.user_stat.height % 12
    "#{feet}' #{inches}\""
  end
end
