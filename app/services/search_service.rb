# frozen_string_literal: true

# Provides centralized search functionality across different models
class SearchService
  # Search health conditions with standardized case-insensitive behavior
  # @param user [User] current user
  # @param search_term [String] search term to filter by
  # @return [ActiveRecord::Relation] filtered health conditions
  def self.search_health_conditions(user, search_term = nil)
    # Get the base query for conditions not already selected by this user
    conditions = HealthCondition.ordered.where.not(id: user.user_health_conditions.pluck(:health_condition_id))

    normalized_search_term = normalize_search_term(search_term)
    return conditions if normalized_search_term.blank?

    conditions.where("health_condition_name LIKE ? COLLATE NOCASE", normalized_search_term)
  end

  # Search health goals with standardized case-insensitive behavior
  # @param user [User] current user
  # @param search_term [String] search term to filter by
  # @return [ActiveRecord::Relation] filtered health goals
  def self.search_health_goals(user, search_term = nil)
    # Get the base query for goals not already selected by this user
    goals = HealthGoal.ordered.where.not(id: user.user_health_goals.pluck(:health_goal_id))

    normalized_search_term = normalize_search_term(search_term)
    return goals if normalized_search_term.blank?

    goals.where("health_goal_name LIKE ? COLLATE NOCASE", normalized_search_term)
  end

  # Search foods with standardized case-insensitive behavior
  # @param user [User] current user
  # @param search_term [String] search term to filter by
  # @return [ActiveRecord::Relation] filtered foods
  def self.search_foods(user, search_term = nil)
    # Get the base query for foods not already selected by this user
    foods = Food.available_for(user, include_qualifiers: true)

    normalized_search_term = normalize_search_term(search_term)
    return foods if normalized_search_term.blank?

    foods.where("food_name LIKE ? COLLATE NOCASE", normalized_search_term)
  end

  def self.normalize_search_term(search_term)
    search_term = search_term.to_s.strip.presence
    return if search_term.blank?

    "%#{search_term}%"
  end
  private_class_method :normalize_search_term
end
