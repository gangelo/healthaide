class Food < ApplicationRecord
  include SoftDeletable

  UNIQUE_SIGNATURE_SEPARATOR = ":".freeze

  before_save :before_save_food_name
  after_update :cleanup_user_foods, if: -> { saved_change_to_deleted_at? && deleted_at.present? }

  has_many :user_foods, inverse_of: :food
  has_many :users, through: :user_foods

  has_many :food_food_qualifiers, inverse_of: :food, dependent: :destroy
  has_many :food_qualifiers, through: :food_food_qualifiers

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

  def food_qualifiers_unique_signature
    return "" if food_qualifiers.empty?

    signature = food_qualifiers.map do |food_qualifier, index|
      "\"#{food_qualifier.qualifier_name.downcase}\""
    end.sort.join(UNIQUE_SIGNATURE_SEPARATOR)

    signature.prepend(UNIQUE_SIGNATURE_SEPARATOR)
  end

  def food_uniqueness
    return if food_name.blank?

    # Skip validation if this is an update and food_name/qualifiers haven't changed
    return if persisted? &&
              !food_name_changed? &&
              !food_qualifiers_updated?

    # Check if any other food has the same signature
    duplicate_exists = Food.where.not(id: id || 0)
                           .kept
                           .any? { |f| f.unique_signature == unique_signature }

    if duplicate_exists
      errors.add(:base, "A food with this name and the same qualifiers already exists")
    end
  end

  # Checks if food qualifiers have been updated
  def food_qualifiers_updated?
    return true if new_record?

    # Compare current qualifier IDs with what's in the database
    persisted_qualifier_ids = Food.includes(:food_qualifiers)
                                 .find(id)
                                 .food_qualifiers
                                 .map(&:id)
                                 .sort

    current_qualifier_ids = food_qualifiers.map(&:id).sort

    persisted_qualifier_ids != current_qualifier_ids
  end

  def before_save_food_name
    self.food_name = normalize_name(self.food_name)
  end

  def cleanup_user_foods
    user_foods.destroy_all if discarded?
  end
end
