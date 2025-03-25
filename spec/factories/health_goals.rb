FactoryBot.define do
  factory :health_goal do
    sequence(:health_goal_name) { |n| "Health Goal #{n}" }
  end
end