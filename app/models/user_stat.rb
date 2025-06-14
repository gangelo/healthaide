class UserStat < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :sex, inclusion: { in: [ "M", "F" ] }, allow_nil: true
  validates :height, numericality: { greater_than_or_equal_to: 48, less_than_or_equal_to: 96 }, allow_nil: true
  validates :muscle_fat_analysis_weight, numericality: { greater_than_or_equal_to: 50.0, less_than_or_equal_to: 500.0 }, allow_nil: true
  validates :muscle_fat_analysis_skeletal_muscle_mass, numericality: { greater_than: 0 }, allow_nil: true
  validates :muscle_fat_analysis_body_fat_mass, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :obesity_analysis_bmi, numericality: { greater_than: 0 }, allow_nil: true
  validates :obesity_analysis_percent_body_fat, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :abdominal_obesity_analysis_waist_hip_ratio, numericality: { greater_than: 0, less_than: 2 }, allow_nil: true
  validates :abdominal_obesity_analysis_visceral_fat_level, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :comprehensive_analysis_basal_metabolic_rate, numericality: { greater_than: 0 }, allow_nil: true
  validates :body_composition_analysis_soft_lean_mass, numericality: { greater_than: 0 }, allow_nil: true

  def to_export_hash
    attributes.symbolize_keys.slice(
      :abdominal_obesity_analysis_visceral_fat_level,
      :abdominal_obesity_analysis_waist_hip_ratio,
      :birthday,
      :body_balance_evaluation_upper_lower,
      :body_composition_analysis_soft_lean_mass,
      :comprehensive_analysis_basal_metabolic_rate,
      :height,
      :muscle_fat_analysis_body_fat_mass,
      :muscle_fat_analysis_cid,
      :muscle_fat_analysis_skeletal_muscle_mass,
      :muscle_fat_analysis_weight,
      :obesity_analysis_bmi,
      :obesity_analysis_percent_body_fat,
      :sex
    )
  end
end
