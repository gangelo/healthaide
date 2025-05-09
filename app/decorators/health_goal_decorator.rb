class HealthGoalDecorator < BaseDecorator
  def formatted_name
    health_goal_name
  end

  def badge_class
    "inline-flex items-center px-3 py-0.5 rounded-full text-sm font-medium bg-green-100 text-green-800"
  end

  def badge_with_priority(priority = nil)
    if priority
      "#{health_goal_name} (Priority: #{priority})"
    else
      health_goal_name
    end
  end

  def with_importance(user_health_goal)
    return health_goal_name unless user_health_goal
    "#{user_health_goal.order_of_importance}. #{health_goal_name}"
  end

  def summary_with_supplements(supplements)
    return health_goal_name if supplements.empty?

    supplement_names = supplements.map(&:user_supplement_name).join(", ")
    "#{health_goal_name} - Supplements: #{supplement_names}"
  end
end
