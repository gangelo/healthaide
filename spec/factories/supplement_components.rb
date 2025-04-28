module FactoryBotHelpers
  def self.supplement_component_name_sample
    [ "Vitamin D3", "Vitamin C", "Zinc", "Magnesium", "Calcium", "Iron", "Omega-3", "Vitamin B12", "Folate", "Biotin" ].sample
  end
end

FactoryBot.define do
  factory :supplement_component do
    sequence(:supplement_component_name) { |n| "#{FactoryBotHelpers.supplement_component_name_sample} #{n}" }
    amount { rand(1..1000).to_s }
    unit { [ "mg", "mcg", "g", "IU", "%" ].sample }
    user_supplement
  end
end
