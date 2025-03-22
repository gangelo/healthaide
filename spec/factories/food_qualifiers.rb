FactoryBot.define do
  factory :food_qualifier do
    qualifier_name { FFaker::FoodQualifier.qualifier }
  end
end
