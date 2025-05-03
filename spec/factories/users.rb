# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    username { "#{first_name[0]}#{last_name.gsub(/[^a-zA-Z]+/, "")}".downcase }
    email { FFaker::Internet.email.sub(/^[^@]+/, "#{first_name}.#{last_name}".downcase) }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    role { User::ROLE_USER }

    trait :admin do
      role { User::ROLE_ADMIN }
    end

    trait :with_stats do
      association :user_stat
    end
  end
end
