# frozen_string_literal: true

FactoryBot.define do
  factory :food do
    food_name { FFaker::FoodPL.food }

    trait :with_food_qualifiers do
      after(:build) do |food|
        food.food_qualifiers << build(:food_qualifier)
      end
    end
  end
end
