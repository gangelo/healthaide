# frozen_string_literal: true

FactoryBot.define do
  factory :user_health_condition do
    user
    health_condition
    order_of_importance { 1 }

    trait :deleted do
      deleted_at { 1.day.ago }
    end
  end
end