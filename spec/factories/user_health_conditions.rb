# frozen_string_literal: true

FactoryBot.define do
  factory :user_health_condition do
    user
    health_condition
  end
end
