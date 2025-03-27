# frozen_string_literal: true

FactoryBot.define do
  factory :health_condition do
    sequence(:health_condition_name) { |n| "Health Condition #{n}" }

    trait :with_users do
      transient do
        users_count { 2 }
      end

      after(:create) do |health_condition, evaluator|
        users = create_list(:user, evaluator.users_count)
        users.each do |user|
          create(:user_health_condition, user: user, health_condition: health_condition)
        end
      end
    end
  end
end
