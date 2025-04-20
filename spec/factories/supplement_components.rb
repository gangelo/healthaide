FactoryBot.define do
  factory :supplement_component do
    name { ["Vitamin D3", "Vitamin C", "Zinc", "Magnesium", "Calcium", "Iron", "Omega-3", "Vitamin B12", "Folate", "Biotin"].sample }
    amount { rand(1..1000).to_s }
    unit { ["mg", "mcg", "g", "IU", "%"].sample }
    user_supplement
  end
end