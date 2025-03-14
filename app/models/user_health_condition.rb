class UserHealthCondition < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  belongs_to :health_condition

  validates :user_id, presence: true
  validates :health_condition_id, presence: true,
            uniqueness: { scope: :user_id, message: "has already been added to your health conditions" }

  scope :ordered, -> { joins(:health_condition).order("health_conditions.health_condition_name") }

  delegate :health_condition_name, to: :health_condition
end
