# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    username { "#{first_name[0]}#{last_name.gsub(/[^a-zA-Z]+/, '')}".downcase }
    email { FFaker::Internet.email.sub(/^[^@]+/, "#{first_name}.#{last_name}".downcase) }
    password { "#{FFaker::Internet.password}Xyz#04" }
  end
end
