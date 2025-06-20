class CreateUserMealPrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :user_meal_prompts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :include_user_medications, default: true
      t.boolean :include_user_stats, default: true
      t.text :food_ids, default: '[]'
      t.text :health_condition_ids, default: '[]'
      t.text :health_goal_ids, default: '[]'
      t.text :user_supplement_ids, default: '[]'
      t.integer :meals_count, default: 3
      t.datetime :generated_at

      t.timestamps
    end
  end
end
