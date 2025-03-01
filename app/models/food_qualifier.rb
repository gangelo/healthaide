class FoodQualifier < ApplicationRecord
  include SoftDeletable

  before_save :before_save_qualifier_name

  has_many :food_food_qualifiers, inverse_of: :food_qualifier, dependent: :destroy
  has_many :foods, through: :food_food_qualifiers

  validates :qualifier_name, presence: true, length: { maximum: 64 }

  scope :by_name, -> { order(:qualifier_name) }

  private

  def before_save_qualifier_name
    self.qualifier_name = self.qualifier_name&.downcase
  end
end
