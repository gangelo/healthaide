class CreateUserStats < ActiveRecord::Migration[8.0]
  def change
    create_table :user_stats do |t|
      t.date :birthday
      t.string :sex, limit: 1
      t.decimal :height, precision: 5, scale: 2            # 48-96 inches
      t.decimal :muscle_fat_analysis_weight, precision: 6, scale: 2  # 50.0-500.0 lbs
      t.decimal :muscle_fat_analysis_skeletal_muscle_mass, precision: 6, scale: 2
      t.decimal :muscle_fat_analysis_body_fat_mass, precision: 6, scale: 2
      t.string :muscle_fat_analysis_cid
      t.decimal :obesity_analysis_bmi, precision: 5, scale: 2
      t.decimal :obesity_analysis_percent_body_fat, precision: 5, scale: 2
      t.decimal :abdominal_obesity_analysis_waist_hip_ratio, precision: 4, scale: 2
      t.integer :abdominal_obesity_analysis_visceral_fat_level
      t.decimal :comprehensive_analysis_basal_metabolic_rate, precision: 8, scale: 2
      t.string :body_balance_evaluation_upper_lower
      t.decimal :body_composition_analysis_soft_lean_mass, precision: 6, scale: 2
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
