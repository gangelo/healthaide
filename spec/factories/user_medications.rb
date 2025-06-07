FactoryBot.define do
  factory :user_medication do
    association :user
    association :medication
  end
end
