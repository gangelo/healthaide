class UserFood < ApplicationRecord
  include SoftDeletable

  before_save :before_save_validations

  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods

  # Order by food food_name
  scope :ordered, -> { joins(:food).order("foods.food_name") }

  validates :user, presence: true, on: :save
  validates :food, presence: true, on: :save
  validates_uniqueness_of :food_id, scope: :user_id, message: "has already been selected"

  private

  def before_save_validations
    return if user.blank? || food.blank?

    if Food.find(food_id)&.discarded?
      errors.add(:food, "'#{food.food_name}' is unavailable")
      return
    end

    # Check if we're restoring a record (deleted_at changing from a value to nil)
    return if deleted_at_was.present? && deleted_at.nil?

    errors.add(:food, "has already been selected") if user.user_foods.kept.where(food_id: food_id).exists?
  end
end
