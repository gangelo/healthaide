class UserMealPromptMessage < ApplicationRecord
  acts_as_message(
    chat_class: "UserMealPromptChat",
    chat_foreign_key: "user_meal_prompt_chat_id",
    tool_call_class: "UserMealPromptToolCall",
    tool_call_foreign_key: "user_meal_prompt_tool_call_id"
  )

  validates :role, presence: true
  validates :chat, presence: true
end
