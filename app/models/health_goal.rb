class HealthGoal < ApplicationRecord
  include NameNormalizable

  has_many :user_health_goals, dependent: :destroy
  has_many :users, through: :user_health_goals

  validates :health_goal_name, presence: true, uniqueness: { case_sensitive: false }

  scope :ordered, -> { order(:health_goal_name) }

  def to_s
    health_goal_name
  end

  private

  def normalize_name
    self.health_goal_name = self.class.normalize_name(self.health_goal_name)
  end
end
