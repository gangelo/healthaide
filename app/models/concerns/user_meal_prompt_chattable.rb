module UserMealPromptChattable
  extend ActiveSupport::Concern

  included do
    # has_many :user_meal_prompt_chats,
    #        class_name: "Ai::UserMealPromptChat",
    #        dependent: :destroy

    # has_many :user_meal_prompt_messages,
    #        through: :user_meal_prompt_chats,
    #        source: :messages,
    #        class_name: "Ai::UserMealPromptMessage"

    # has_many :meal_prompt_tool_calls,
    #        through: :user_meal_prompt_messages,
    #        source: :tool_calls,
    #        class_name: "Ai::UserMealPromptToolCall"
    has_many :user_meal_prompt_chats
    # has_many :meal_chats, class_name: "Ai::UserMealPromptChat"
  end
end
