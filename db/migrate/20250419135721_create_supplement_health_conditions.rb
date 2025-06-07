class CreateSupplementHealthConditions < ActiveRecord::Migration[8.0]
  def change
    create_table :supplement_health_conditions do |t|
      t.references :user_supplement, null: false, foreign_key: true
      t.references :health_condition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
