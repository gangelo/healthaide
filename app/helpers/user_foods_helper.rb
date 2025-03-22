module UserFoodsHelper
  # Returns a formatted selection count text
  # @param count [Integer] the number of selected foods
  # @return [String] a formatted string
  def selection_count_text(count)
    "#{count} #{"food".pluralize(count)} selected"
  end

  # Returns a collection of available foods for the user with optional includes
  # @param user [User] the user to get available foods for
  # @param include_qualifiers [Boolean] whether to include food qualifiers
  # @return [ActiveRecord::Relation] foods available to the user
  def available_foods_with_includes(user, include_qualifiers: false)
    foods = Food.available_for(user)
    foods = foods.includes(:food_qualifiers) if include_qualifiers
    foods
  end
end
