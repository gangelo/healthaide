class UserFood < ApplicationRecord
  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods

  validate :food_not_already_selected
  validate :food_not_deleted

  scope :ordered, -> { joins(:food).order("foods.food_name") }

  def to_h
    attributes.symbolize_keys.tap do |hash|
      hash[:food] = food.to
    end
  end

  private

  def food_not_already_selected
    return if user.blank? || food.blank?

    errors.add(:food, "has already been selected") if food_already_selected?
  end

  def food_not_deleted
    return if user.blank? || food.blank?

    errors.add(:food, "'#{food.food_name}' is unavailable") if food_discarded?
  end

  def food_discarded?
    return Food.find(food_id)&.discarded? if food_id.present?

    Food.find_by_food_name_normalized(food.food_name)&.discarded? if food.present?
  end

  def food_already_selected?
    return user.user_foods.exists?(food_id: food_id) if food_id.present?

    user.user_foods.joins(:food).exists?(foods: { food_name: food.food_name }) if food.present?
  end
end
