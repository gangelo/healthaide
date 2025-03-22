class UserFood < ApplicationRecord
  include SoftDeletable

  # before_save :before_save_validations

  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods

  # Order by food food_name
  scope :ordered, -> { joins(:food).order("foods.food_name") }

  # validates :user, presence: true, on: :create
  # validates :food, presence: true, on: :create
  validates_uniqueness_of :food_id, scope: :user_id, message: "has already been selected"
end
