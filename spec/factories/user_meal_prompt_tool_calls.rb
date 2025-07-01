FactoryBot.define do
  factory :user_meal_prompt_tool_call do
    user_meal_prompt_message { nil }
    tool_call_id { "MyString" }
    name { "MyString" }
    arguments { "MyText" }
  end
end
