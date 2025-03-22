class HealthGoal < ApplicationRecord
  before_save :before_save_health_goal_name

  has_many :user_health_goals, dependent: :destroy
  has_many :users, through: :user_health_goals

  validates :health_goal_name, presence: true, uniqueness: { case_sensitive: false }

  scope :ordered, -> { order(:health_goal_name) }

  def to_s
    health_goal_name
  end

  private

  def before_save_health_goal_name
    self.health_goal_name = self.health_goal_name&.downcase&.capitalize
  end
end
