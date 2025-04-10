class FoodQualifier < ApplicationRecord
  include NameNormalizable
  include SoftDeletable

  before_validation :normalize_name, if: :qualifier_name_changed?
  before_destroy :ensure_not_in_use

  has_many :food_food_qualifiers, inverse_of: :food_qualifier, dependent: :destroy
  has_many :foods, through: :food_food_qualifiers

  validates :qualifier_name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 64 }

  scope :ordered, -> { order(:qualifier_name) }

  def to_export_hash
    {
    food_qualifier: attributes.symbolize_keys
    }
  end

  private

  def normalize_name
    self.qualifier_name = self.class.normalize_name(self.qualifier_name)
  end

  def ensure_not_in_use
    if foods.any?
      errors.add(:base, "Food qualifier is being used and cannot be deleted")
      throw :abort
    end
  end
end
