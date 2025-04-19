FactoryBot.define do
  factory :user_stat do
    birthday { 30.years.ago }
    sex { [ "M", "F" ].sample }
    height { rand(60..75) }  # 5' to 6'3" in inches
    muscle_fat_analysis_weight { rand(130..220) }  # lbs
    muscle_fat_analysis_skeletal_muscle_mass { rand(40..80) }  # lbs
    muscle_fat_analysis_body_fat_mass { rand(15..60) }  # lbs
    muscle_fat_analysis_cid { [ "Average B-type", "Above average C-type", "Below average D-type" ].sample }
    obesity_analysis_bmi { rand(18..35) }  # kg/m²
    obesity_analysis_percent_body_fat { rand(10..35) }  # %
    abdominal_obesity_analysis_waist_hip_ratio { (rand(0.7..1.1)).round(2) }
    abdominal_obesity_analysis_visceral_fat_level { rand(1..15) }
    comprehensive_analysis_basal_metabolic_rate { rand(1200..2500) }  # kJ
    body_balance_evaluation_upper_lower { [ "Balanced", "Slightly unbalanced", "Moderately unbalanced" ].sample }
    body_composition_analysis_soft_lean_mass { rand(90..160) }  # lbs
    association :user
  end
end
