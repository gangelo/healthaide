class UserHealthGoal < ApplicationRecord
  belongs_to :user
  belongs_to :health_goal

  validates :order_of_importance, presence: true,
                                numericality: { only_integer: true,
                                              greater_than_or_equal_to: 1,
                                              less_than_or_equal_to: 25 }
  validates :health_goal_id, uniqueness: { scope: :user_id, message: "has already been added to your goals" }

  scope :ordered_by_importance, -> do
    includes(:health_goal).order(order_of_importance: :asc, health_goals: { health_goal_name: :asc })
  end

  def to_export_hash
    {
    user_health_goal: attributes.symbolize_keys.slice(:order_of_importance).tap do |hash|
      hash.merge!(health_goal.to_export_hash)
    end
    }
  end
end
