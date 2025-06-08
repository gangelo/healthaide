FactoryBot.define do
  factory :user_medication do
    association :user
    association :medication
    frequency { Frequentable::FREQUENCIES.keys.sample }
  end
end
