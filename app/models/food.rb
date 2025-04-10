class Food < ApplicationRecord
  include NameNormalizable
  include SoftDeletable

  UNIQUE_SIGNATURE_SEPARATOR = ":".freeze

  after_update :cleanup_user_foods, if: -> { saved_change_to_deleted_at? && deleted_at.present? }

  has_many :user_foods, inverse_of: :food, dependent: :destroy
  has_many :users, through: :user_foods

  has_many :food_food_qualifiers, inverse_of: :food, dependent: :destroy
  has_many :food_qualifiers, -> { kept }, through: :food_food_qualifiers

  validates :food_name, presence: true, length: { maximum: 64 }
  validate :food_uniqueness

  # Returns a human-readable display name including qualifiers
  def display_name_with_qualifiers
    if food_qualifiers.any?
      qualifier_text = food_qualifiers.map(&:qualifier_name).sort.join(", ")
      "#{food_name} (#{qualifier_text})"
    else
      food_name
    end
  end

  scope :ordered, -> { order(:food_name) }
  scope :not_selected_by, ->(user) { where.not(id: user.user_foods.select(:food_id)) }
  scope :available_for, ->(user, include_qualifiers: false) do
    results = kept.ordered.not_selected_by(user)
    results = results.includes(:food_qualifiers) if include_qualifiers
    results
  end

  def to_export_hash
    {
    food: attributes.symbolize_keys.tap do |hash|
      hash[:food_qualifiers] = []

      food_qualifiers.each_with_index do |food_qualifier, index|
        hash[:food_qualifiers][index] = food_qualifier.to_export_hash
      end
    end
    }
  end

  def self.find_by_food_name_normalized(food_name)
    find_by(food_name: normalize_name(food_name))
  end

  def includes_qualifier?(qualifier)
    food_qualifiers.include?(qualifier)
  end

  # Returns a unique string signature for this food combining name and qualifiers
  def unique_signature
    "\"#{food_name.downcase}\"#{food_qualifiers_unique_signature}"
  end

  private

  def normalize_name
    self.food_name = self.class.normalize_name(self.food_name)
  end

  def food_qualifiers_unique_signature
    return "" if food_qualifiers.empty?

    signature = food_qualifiers.map do |food_qualifier|
      "\"#{food_qualifier.qualifier_name.downcase}\""
    end.sort.join(UNIQUE_SIGNATURE_SEPARATOR)

    signature.prepend(UNIQUE_SIGNATURE_SEPARATOR)
  end

  def food_uniqueness
    return if food_name.blank?

    # Check if any other food has the same signature
    duplicate_food = Food.where.not(id: id || 0)
                         .find { it.unique_signature == unique_signature }

    if duplicate_food
      if duplicate_food.discarded?
        errors.add(:base, "A deleted food with this name and the same qualifiers already exists")
      else
        errors.add(:base, "A food with this name and the same qualifiers already exists")
      end
    end
  end

  # Keep this method for backward compatibility, but it's no longer used
  def food_qualifiers_updated?
    true
  end

  def cleanup_user_foods
    user_foods.destroy_all if discarded?
  end
end
