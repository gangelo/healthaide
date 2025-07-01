class UserMealPromptChat < ApplicationRecord
  acts_as_chat(
    message_class: "UserMealPromptMessage",
    tool_call_class: "UserMealPromptToolCall"
  )

  belongs_to :user, optional: true

  validates :model_id, presence: true
end
