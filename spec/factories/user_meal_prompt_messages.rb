FactoryBot.define do
  factory :user_meal_prompt_message do
    user_meal_prompt_chat { nil }
    role { "MyString" }
    content { "MyText" }
    model_id { "MyString" }
    input_tokens { 1 }
    output_tokens { 1 }
    user_meal_prompt_tool_call { nil }
  end
end
