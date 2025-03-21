class UserFood < ApplicationRecord
  include SoftDeletable

  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods

  # Order by food food_name
  scope :ordered, -> { joins(:food).order("foods.food_name") }
end
