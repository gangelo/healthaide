class HealthCondition < ApplicationRecord
  include NameNormalizable

  has_many :user_health_conditions, dependent: :destroy
  has_many :users, through: :user_health_conditions

  validates :health_condition_name,
            presence: true,
            length: { minimum: 2, maximum: 64 },
            uniqueness: { case_sensitive: false },
            format: {
              with: VALID_NAME_REGEX,
              message: INVALID_NAME_REGEX_MESSAGE
            }

  scope :ordered, -> { order(:health_condition_name) }

  def to_s
    health_condition_name
  end

  def to_export_hash
    {
      health_condition: attributes.symbolize_keys.slice(:health_condition_name)
    }
  end

  private

  def normalize_name
    self.health_condition_name = self.class.normalize_name(self.health_condition_name)
  end
end
