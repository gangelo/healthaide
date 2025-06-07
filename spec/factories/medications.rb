# frozen_string_literal: true

FactoryBot.define do
  factory :medication do
    sequence(:medication_name) { |n| "Medication #{n}" }
  end
end