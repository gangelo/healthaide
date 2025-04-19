# frozen_string_literal: true

# Extend FFaker with a FoodQualifier module if it doesn't exist
module FFaker
  module FoodQualifier
    extend ModuleUtils
    extend self

    def qualifier
      %w[Organic Fresh Local Imported Frozen Raw Cooked Dried Smoked Salted Fermented
         Spicy Sweet Sour Bitter Grilled Roasted Baked Fried Boiled Steamed
         Natural Seasonal Wild Farmed Grass-fed Free-range Non-GMO Vegetarian Vegan].sample
    end
  end
end

FactoryBot.define do
  factory :food_qualifier do
    qualifier_name { FFaker::FoodQualifier.qualifier }
  end
end
