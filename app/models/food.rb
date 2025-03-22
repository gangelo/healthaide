class Food < ApplicationRecord
  include SoftDeletable

  before_save :before_save_food_name

  has_many :user_foods, inverse_of: :food, dependent: :destroy
  has_many :users, through: :user_foods

  has_many :food_food_qualifiers, inverse_of: :food, dependent: :destroy
  has_many :food_qualifiers, through: :food_food_qualifiers

  validates :food_name, presence: true, uniqueness: true, length: { maximum: 64 }

  scope :ordered, -> { order(:food_name) }
  scope :not_selected_by, ->(user) { where.not(id: user.user_foods.select(:food_id)) }
  scope :available_for, ->(user) { ordered.not_selected_by(user) }

  class << self
    def find_by_food_name_normalized(food_name)
      find_by(food_name: normalize_food_name(food_name))
    end

    def normalize_food_name(food_name)
      food_name&.downcase&.capitalize
    end
  end

  private

  def before_save_food_name
    self.food_name = self.class.normalize_food_name(self.food_name)
  end
end
