class UserMealPromptDecorator < BaseDecorator
  def full_formatted_prompt
    sections = []

    sections << formatted_instructions
    sections << formatted_available_foods_section
    sections << with_line_before(formatted_health_profile) if include_user_stats?
    sections << with_line_before(formatted_user_supplements) unless user_supplements.empty?
    sections << with_line_before(formatted_user_medications) if include_user_medications? && user.user_medications.any?
    sections << with_line_before(formatted_health_goals)

    sections.join("\n")
  end

  def formatted_instructions
    <<~CONTENT
      INSTRUCTIONS:

      CREATE EACH MEAL USING MY AVAILABLE FOODS THAT SPECIFICALLY SUPPORTS MY HEALTH NEEDS:

      PROVIDE EXACLY [#{meals_count}] #{pluralize_meals_count} WITH:
      - Specific portions (oz/cups), DO NOT PROVIDE RECIPES!!!
      - Which foods to use (#{formatted_food_examples}).
      - EXPLAIN HOW each meal directly supports my health conditions and priorities.
    CONTENT
  end

  def formatted_available_foods_section
    content = [ "AVAILABLE FOODS:" ]

    if foods.empty?
      content << "[No foods selected]"
    else
      foods.each { |food| content << "- #{food.food_name}" }
    end

    content.join("\n")
  end

  def formatted_health_profile
    return "" unless include_user_stats? && user.user_stat.present?

    content = [ "MY HEALTH PROFILE:" ]
    content << "- #{formatted_user_stats}"
    content << "- #{formatted_health_contitions}" if health_conditions.any?

    content.join("\n")
  end

  def formatted_health_contitions
    return unless health_conditions.any?

    "Conditions: #{health_conditions.map(&:health_condition_name).join(", ")}"
  end

  def formatted_user_stats
    user_stat = user.user_stat
    return "" unless user_stat

    content = []

    # Basic demographics
    content << (user_stat.sex == "M" ? "Male" : "Female") if user_stat.sex?
    content << calculate_age if user_stat.birthday?
    content << formatted_height if user_stat.height?

    # Weight and body composition
    content << "#{user_stat.muscle_fat_analysis_weight} lbs" if user_stat.muscle_fat_analysis_weight?
    content << "BMI: #{user_stat.obesity_analysis_bmi}" if user_stat.obesity_analysis_bmi?
    content << "#{user_stat.obesity_analysis_percent_body_fat}% body fat" if user_stat.obesity_analysis_percent_body_fat?

    # Additional measurements if available
    content << "#{user_stat.muscle_fat_analysis_skeletal_muscle_mass} lbs muscle mass" if user_stat.muscle_fat_analysis_skeletal_muscle_mass?
    content << "#{user_stat.muscle_fat_analysis_body_fat_mass} lbs fat mass" if user_stat.muscle_fat_analysis_body_fat_mass?
    content << "Waist hip ratio: #{user_stat.abdominal_obesity_analysis_waist_hip_ratio}" if user_stat.abdominal_obesity_analysis_waist_hip_ratio?
    content << "Visceral fat level: #{user_stat.abdominal_obesity_analysis_visceral_fat_level}" if user_stat.abdominal_obesity_analysis_visceral_fat_level?
    content << "Basal metabolic rate (BMR): #{user_stat.comprehensive_analysis_basal_metabolic_rate} (kJ)" if user_stat.comprehensive_analysis_basal_metabolic_rate?
    content << "Soft lean mass: #{user_stat.body_composition_analysis_soft_lean_mass} lbs" if user_stat.body_composition_analysis_soft_lean_mass?

    content.join(", ")
  end

  def formatted_user_supplements
    content = [ "SUPPLEMENTS:" ]

    user_supplements.each do |user_supplement|
      content << "- #{format_supplement(user_supplement)}"
    end

    content.join("\n")
  end

  def format_supplement(user_supplement)
    return format_supplement_with_components(user_supplement) if user_supplement.supplement_components.any?

    content = [ user_supplement.user_supplement_name ]
    content << "#{user_supplement.dosage} #{user_supplement.dosage_unit}" if user_supplement.dosage?
    content << humanize(user_supplement.frequency)

    content.join(", ")
  end

  def format_supplement_with_components(user_supplement)
    components = user_supplement.supplement_components.map do |supplement_component|
      "#{supplement_component.supplement_component_name} #{supplement_component.amount} #{supplement_component.unit}"
    end.join(", ")

    "#{user_supplement.user_supplement_name} (#{components})"
  end

  def humanize(object, downcase: true)
    humanized = object.to_s.humanize

    downcase ? humanized.downcase : humanized
  end

  def formatted_user_medications
    content = [ "MEDICATIONS:" ]

    user.user_medications.each do |user_medication|
      content << "- #{user_medication.medication.medication_name}"
    end

    content.join("\n")
  end

  def formatted_health_goals
    return formatted_empty_health_goals if health_goals.empty?

    content = [ "HEALTH PRIORITIES (MUST ADDRESS THESE, IN ORDER OF IMPORTANCE):" ]

    user.health_goals_grouped_by_importance.each do |importance_level, user_health_goals_array|
      content << "#{importance_level}: "
      content.last << user_health_goals_array.map { |user_health_goal| user_health_goal.health_goal.health_goal_name }.join(", ")
    end

    content.join("\n")
  end

  def formatted_empty_health_goals
    <<~EMPTY_GOALS
      HEALTH PRIORITIES (MUST ADDRESS THESE, IN ORDER OF IMPORTANCE):
      [No health goals selected]
    EMPTY_GOALS
  end

  def formatted_food_examples
    "#{foods.take(3).map(&:food_name).join(", ")}, etc."
  end

  def pluralize_meals_count
    "MEAL".pluralize(meals_count).upcase
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

  def with_line_before(content)
    with_lines_before(content, lines: 1)
  end

  def with_lines_before(content, lines: 2)
    lines = "\n" * lines
    "#{lines}#{content}"
  end
end
