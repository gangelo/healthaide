class HealthCondition < ApplicationRecord
  include SoftDeletable

  before_save :before_save_health_condition_name

  has_many :user_health_conditions, dependent: :destroy
  has_many :users, through: :user_health_conditions

  validates :health_condition_name,
            presence: true,
            length: { minimum: 2, maximum: 64 },
            uniqueness: { case_sensitive: false, conditions: -> { where(deleted_at: nil) } }

  scope :ordered, -> { order(:health_condition_name) }

  def to_s
    health_condition_name
  end

  private

  def before_save_health_condition_name
    self.health_condition_name = self.health_condition_name&.downcase&.capitalize
  end
end
