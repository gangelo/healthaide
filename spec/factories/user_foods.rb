# frozen_string_literal: true

FactoryBot.define do
  factory :user_food do
    association :user
    association :food
  end
end
