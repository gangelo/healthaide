class UserFood < ApplicationRecord
  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods

  accepts_nested_attributes_for :food, reject_if: :all_blank

  validate :food_not_already_selected

  scope :ordered, -> { joins(:food).order("foods.food_name") }

  def to_export_hash
    {
    user_food: attributes.symbolize_keys.tap do |hash|
      hash.merge!(food.to_export_hash)
    end
    }
  end

  private

  def food_not_already_selected
    return if user.blank? || food.blank?

    errors.add(:food, "has already been selected") if food_already_selected?
  end


  def food_already_selected?
    return user.user_foods.exists?(food_id: food_id) if food_id.present?

    user.user_foods.joins(:food).exists?(foods: { food_name: food.food_name }) if food.present?
  end
end
