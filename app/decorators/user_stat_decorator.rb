class UserStatDecorator < BaseDecorator
  def formatted_sex
    return "N/A" unless sex.present?
    sex == "M" ? "Male" : "Female"
  end

  def formatted_height
    return "N/A" unless height.present?
    feet = height / 12
    inches = height % 12
    "#{feet}' #{inches}\""
  end

  def formatted_weight
    return "N/A" unless muscle_fat_analysis_weight.present?
    "#{muscle_fat_analysis_weight} lbs"
  end

  def formatted_bmi
    return "N/A" unless obesity_analysis_bmi.present?
    "#{obesity_analysis_bmi}"
  end

  def formatted_body_fat_percentage
    return "N/A" unless obesity_analysis_percent_body_fat.present?
    "#{obesity_analysis_percent_body_fat}%"
  end

  def formatted_skeletal_muscle_mass
    return "N/A" unless muscle_fat_analysis_skeletal_muscle_mass.present?
    "#{muscle_fat_analysis_skeletal_muscle_mass} lbs"
  end

  def formatted_body_fat_mass
    return "N/A" unless muscle_fat_analysis_body_fat_mass.present?
    "#{muscle_fat_analysis_body_fat_mass} lbs"
  end

  def formatted_waist_hip_ratio
    return "N/A" unless abdominal_obesity_analysis_waist_hip_ratio.present?
    "#{abdominal_obesity_analysis_waist_hip_ratio}"
  end

  def formatted_visceral_fat_level
    return "N/A" unless abdominal_obesity_analysis_visceral_fat_level.present?
    "#{abdominal_obesity_analysis_visceral_fat_level}"
  end

  def formatted_basal_metabolic_rate
    return "N/A" unless comprehensive_analysis_basal_metabolic_rate.present?
    "#{comprehensive_analysis_basal_metabolic_rate} kJ"
  end

  def formatted_soft_lean_mass
    return "N/A" unless body_composition_analysis_soft_lean_mass.present?
    "#{body_composition_analysis_soft_lean_mass} lbs"
  end

  def calculate_age
    return "N/A" unless birthday.present?
    ((Date.today - birthday) / 365.25).to_i
  end

  def formatted_age
    "#{calculate_age} years"
  end

  def basic_stats_summary
    stats = []
    stats << formatted_sex if sex.present?
    stats << formatted_age if birthday.present?
    stats << formatted_height if height.present?
    stats << formatted_weight if muscle_fat_analysis_weight.present?

    stats.join(", ")
  end

  def body_composition_summary
    stats = []
    stats << "BMI: #{formatted_bmi}" if obesity_analysis_bmi.present?
    stats << "Body fat: #{formatted_body_fat_percentage}" if obesity_analysis_percent_body_fat.present?
    stats << "Muscle mass: #{formatted_skeletal_muscle_mass}" if muscle_fat_analysis_skeletal_muscle_mass.present?
    stats << "Fat mass: #{formatted_body_fat_mass}" if muscle_fat_analysis_body_fat_mass.present?

    stats.join(", ")
  end
end
