FactoryBot.define do
  factory :user_supplement do
    user_supplement_name { FFaker::Product.product_name }
    form { UserSupplement.forms.keys.sample }
    frequency { UserSupplement.frequencies.keys.sample }
    dosage { rand(1..1000).to_s }
    dosage_unit { [ "mg", "mcg", "g", "IU" ].sample }
    manufacturer { FFaker::Company.name }
    notes { FFaker::Lorem.sentence }
    user

    trait :with_components do
      transient do
        components_count { 2 }
      end

      after(:create) do |user_supplement, evaluator|
        create_list(:supplement_component, evaluator.components_count, user_supplement: user_supplement)
      end
    end

    trait :with_health_conditions do
      transient do
        health_conditions_count { 2 }
      end

      after(:create) do |user_supplement, evaluator|
        health_conditions = create_list(:health_condition, evaluator.health_conditions_count)
        health_conditions.each do |health_condition|
          create(:supplement_health_condition, user_supplement: user_supplement, health_condition: health_condition)
        end
      end
    end

    trait :with_health_goals do
      transient do
        health_goals_count { 2 }
      end

      after(:create) do |user_supplement, evaluator|
        health_goals = create_list(:health_goal, evaluator.health_goals_count)
        health_goals.each do |health_goal|
          create(:supplement_health_goal, user_supplement: user_supplement, health_goal: health_goal)
        end
      end
    end

    factory :complete_user_supplement do
      with_components
      with_health_conditions
      with_health_goals
    end
  end
end
