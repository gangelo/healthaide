FactoryBot.define do
  factory :user_health_goal do
    user
    health_goal
    order_of_importance { rand(1..25) }
  end
end
