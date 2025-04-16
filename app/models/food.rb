class Food < ApplicationRecord
  include NameNormalizable

  has_many :user_foods, inverse_of: :food, dependent: :destroy
  has_many :users, through: :user_foods

  has_many :food_food_qualifiers, inverse_of: :food, dependent: :destroy
  has_many :food_qualifiers, through: :food_food_qualifiers

  accepts_nested_attributes_for :food_food_qualifiers,
    allow_destroy: true,
    reject_if: proc { |attributes| attributes["food_qualifier_id"].blank? }

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

  def food_qualifier_ids_with_destroy
    # Returns a hash of food_qualifier_id => _destroy values
    food_food_qualifiers.each_with_object({}) do |food_food_qualifier, hash|
      hash[food_food_qualifier.food_qualifier_id] = food_food_qualifier.marked_for_destruction? ? "1" : "0"
    end
  end

  def normalize_name
    self.food_name = self.class.normalize_name(self.food_name)
  end
end
