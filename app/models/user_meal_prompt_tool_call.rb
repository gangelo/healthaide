class UserMealPromptToolCall < ApplicationRecord
  acts_as_tool_call(
    message_class: "UserMealPromptMessage",
    message_foreign_key: "user_meal_prompt_message_id"
  )
  serialize :arguments, coder: JSON
end
