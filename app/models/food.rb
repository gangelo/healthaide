class Food < ApplicationRecord
  include NameNormalizable

  has_many :user_foods, inverse_of: :food, dependent: :destroy
  has_many :users, through: :user_foods

  validates :food_name,
            presence: true,
            uniqueness: true,
            length: { maximum: 64 },
            format: {
              with: VALID_NAME_REGEX,
              message: INVALID_NAME_REGEX_MESSAGE
            }

  scope :ordered, -> { order(:food_name) }
  scope :not_selected_by, ->(user) { where.not(id: user.user_foods.select(:food_id)) }
  scope :available_for, ->(user) { ordered.not_selected_by(user) }

  # Find a food by its normalized name
  def self.find_by_food_name_normalized(food_name)
    find_by(food_name: normalize_name(food_name))
  end

  def to_export_hash
    {
      food: {
        food_name: food_name
      }
    }
  end

  def normalize_name
    self.food_name = self.class.normalize_name(self.food_name)
  end
end
