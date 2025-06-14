class UserFood < ApplicationRecord
  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods

  accepts_nested_attributes_for :food, reject_if: :all_blank

  validates :food, uniqueness: { scope: :user_id, message: "has already been selected" }

  scope :ordered, -> { includes(:food).order("foods.food_name") }

  def to_export_hash
    {
    user_food: food.to_export_hash
    }
  end
end
