class CreateUserMealPromptChats < ActiveRecord::Migration[8.0]
  def change
    create_table :user_meal_prompt_chats do |t|
      t.string :model_id
      t.references :user

      t.timestamps
    end
  end
end
