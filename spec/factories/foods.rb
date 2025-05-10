# frozen_string_literal: true

FactoryBot.define do
  factory :food do
    sequence(:food_name) { |n| "Test Food #{n}" }
  end
end
