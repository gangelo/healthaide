class MealPrompt < ApplicationRecord
  belongs_to :user

  # Serialize array attributes
  serialize :food_ids, coder: JSON
  serialize :health_condition_ids, coder: JSON
  serialize :health_goal_ids, coder: JSON
  serialize :supplement_ids, coder: JSON

  # Set empty array defaults
  after_initialize do
    self.food_ids ||= []
    self.health_condition_ids ||= []
    self.health_goal_ids ||= []
    self.supplement_ids ||= []
  end

  validates :meals_count, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 21
  }

  # Convenience methods for associations with proper ordering
  def foods
    Food.where(id: food_ids).ordered
  end

  def health_conditions
    HealthCondition.where(id: health_condition_ids).ordered
  end

  def health_goals
    # Access the health goals through the user's health goal records to preserve the ordering
    user.user_health_goals
        .where(health_goal_id: health_goal_ids)
        .ordered_by_importance
        .includes(:health_goal)
        .map(&:health_goal)
  end

  def supplements
    UserSupplement
      .where(id: supplement_ids)
      .includes(:supplement_components)
      .ordered
  end
end
