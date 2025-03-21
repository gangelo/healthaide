class Food < ApplicationRecord
  include SoftDeletable

  before_save :before_save_food_name

  has_many :user_foods, inverse_of: :food, dependent: :destroy
  has_many :users, through: :user_foods

  has_many :food_food_qualifiers, inverse_of: :food, dependent: :destroy
  has_many :food_qualifiers, through: :food_food_qualifiers

  validates :food_name, presence: true, uniqueness: true, length: { maximum: 64 }

  scope :ordered, -> { order(:food_name) }

  private

  def before_save_food_name
    self.food_name = self.food_name&.downcase&.capitalize
  end
end
