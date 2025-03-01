class FoodFoodQualifier < ApplicationRecord
  include SoftDeletable

  belongs_to :food, inverse_of: :food_food_qualifiers
  belongs_to :food_qualifier, inverse_of: :food_food_qualifiers

  validates :food_id, uniqueness: { scope: :food_qualifier_id }
end
