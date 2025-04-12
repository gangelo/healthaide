# frozen_string_literal: true

FactoryBot.define do
  factory :food do
    sequence(:food_name) { |n| "#{FFaker::FoodPL.food} #{n}" }

    trait :with_food_qualifiers do
      transient do
        qualifiers_count { 1 }
      end

      after(:build) do |food, evaluator|
        evaluator.qualifiers_count.times do
          food.food_qualifiers << build(:food_qualifier)
        end
      end
    end

    trait :with_specific_qualifiers do
      transient do
        qualifier_names { [] }
      end

      after(:build) do |food, evaluator|
        evaluator.qualifier_names.each do |name|
          food.food_qualifiers << build(:food_qualifier, qualifier_name: name)
        end
      end
    end

  end
end
