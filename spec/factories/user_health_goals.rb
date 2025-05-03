FactoryBot.define do
  factory :user_health_goal do
    order_of_importance { rand(1..25) }
    user
    health_goal
  end
end
