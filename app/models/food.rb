class Food < ApplicationRecord
  include NameNormalizable

  UNIQUE_SIGNATURE_SEPARATOR = ":".freeze

  before_validation :update_unique_signature
  validate :validate_unique_signature

  has_many :user_foods, inverse_of: :food, dependent: :destroy
  has_many :users, through: :user_foods

  has_many :food_food_qualifiers, inverse_of: :food, dependent: :destroy
  has_many :food_qualifiers, through: :food_food_qualifiers

  validates :food_name, presence: true, length: { maximum: 64 }

  scope :ordered, -> { order(:food_name) }
  scope :not_selected_by, ->(user) { where.not(id: user.user_foods.select(:food_id)) }
  scope :available_for, ->(user, include_qualifiers: false) do
    scope = ordered.not_selected_by(user)
    include_qualifiers ? scope.with_qualifiers : scope
  end
  scope :with_qualifiers, -> { includes(:food_qualifiers) }
  scope :having_qualifiers, ->(qualifier_ids) do
    joins(:food_qualifiers).where(food_qualifiers: qualifier_ids)
  end

  # Find a food by its normalized name
  def self.find_by_food_name_normalized(food_name)
    find_by(food_name: normalize_name(food_name))
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

  # Returns a human-readable display name including qualifiers
  def display_food_qualifiers
    food_qualifiers.map(&:qualifier_name).sort.join(", ")
  end

  def includes_qualifier?(qualifier)
    food_qualifiers.include?(qualifier)
  end

  # Returns a unique string signature for this food combining name and qualifiers
  # This is now for display purposes - the actual signature is stored in the database
  def unique_signature
    self[:unique_signature] || calculate_unique_signature
  end

  private

  # Updates the stored unique_signature attribute
  def update_unique_signature
    self[:unique_signature] = calculate_unique_signature
  end

  # Calculates the unique signature based on food qualifier IDs only
  def calculate_unique_signature
    # Convert to array to handle both saved and unsaved qualifiers
    qualifier_ids = food_qualifiers.filter_map(&:id).sort
    return "" if qualifier_ids.empty?

    qualifier_ids.join(UNIQUE_SIGNATURE_SEPARATOR)
  end

  # Custom validation for unique combination of food name and qualifiers
  def validate_unique_signature
    return if food_name.blank?

    # Food must be unique by name and qualifiers.
    # For a new food, check if a food with this name and exact set of qualifiers exists,
    # if it exists, this is an error.
    # For example, "Apple" with qualifiers "Organic" and "Fresh" should be unique if
    # "Apple" with qualifiers "Organic" and "<anything but 'Fresh'>" already exists.

    # First, check for existing foods with the same name
    existing_foods = Food.where.not(id: id).where(food_name: food_name)

    return if existing_foods.none?

    # If there's a food with the same name, check if it has the same qualifiers
    current_qualifier_ids = food_qualifiers.filter_map(&:id).sort

    existing_foods.each do |existing_food|
      # If the qualifier collections are identical, it's a duplicate
      if current_qualifier_ids == existing_food.food_qualifiers.map(&:id).sort
        errors.add(:unique_signature, "A food with this name and the same qualifiers already exists")
        break
      end
    end
  end

  def normalize_name
    self.food_name = self.class.normalize_name(self.food_name)
  end
end
