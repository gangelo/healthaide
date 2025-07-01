class CreateUserMealPromptToolCalls < ActiveRecord::Migration[8.0]
  def change
    create_table :user_meal_prompt_tool_calls do |t|
      t.references :user_meal_prompt_message, null: false, foreign_key: true
      t.string :tool_call_id, null: false, index: { unique: true }
      t.string :name, null: false
      t.text :arguments, default: "{}"

      t.timestamps
    end
  end
end
