class CreateUserMealPromptMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :user_meal_prompt_messages do |t|
      t.references :user_meal_prompt_chat, null: false, foreign_key: true
      t.references :user_meal_prompt_tool_call
      t.string :role
      t.text :content
      t.string :model_id
      t.integer :input_tokens
      t.integer :output_tokens

      t.timestamps
    end
  end
end
