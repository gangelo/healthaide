# frozen_string_literal: true

FactoryBot.define do
  factory :meal_prompt do
    association :user
    meals_count { 3 }
    include_user_stats { true }
    food_ids { [] }
    health_condition_ids { [] }
    health_goal_ids { [] }
    supplement_ids { [] }
  end
end
