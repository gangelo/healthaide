# frozen_string_literal: true

FactoryBot.define do
  factory :user_food do
    association :user
    association :food

    trait :available do
      available { true }
    end

    trait :not_available do
      available { false }
    end

    trait :favorite do
      favorite { true }
    end

    trait :not_favorite do
      favorite { false }
    end
  end
end
