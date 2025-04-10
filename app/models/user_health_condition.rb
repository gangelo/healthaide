class UserHealthCondition < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  belongs_to :health_condition

  attr_accessor :new_health_condition_name

  validates :user_id, presence: true
  validates :health_condition_id, presence: true,
            uniqueness: { scope: :user_id, message: "has already been added to your health conditions" }

  scope :ordered, -> { joins(:health_condition).order("health_conditions.health_condition_name") }

  def to_export_hash
    {
    user_health_condition: attributes.symbolize_keys.tap do |hash|
        hash.merge!(health_condition.to_export_hash)
      end
    }
  end

  def health_condition_name
    health_condition&.health_condition_name
  end
end
