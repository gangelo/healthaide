json.extract! user_stat, :id, :birthday, :sex, :height, :muscle_fat_analysis_weight, :muscle_fat_analysis_skeletal_muscle_mass, :muscle_fat_analysis_body_fat_mass, :muscle_fat_analysis_cid, :obesity_analysis_bmi, :obesity_analysis_percent_body_fat, :abdominal_obesity_analysis_waist_hip_ratio, :abdominal_obesity_analysis_visceral_fat_level, :comprehensive_analysis_basal_metabolic_rate, :body_balance_evaluation_upper_lower, :body_composition_analysis_soft_lean_mass, :user_id, :created_at, :updated_at
json.url user_stat_url(user_stat, format: :json)
