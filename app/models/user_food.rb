class UserFood < ApplicationRecord
  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods

  accepts_nested_attributes_for :food, reject_if: :all_blank

  validates :food, uniqueness: { scope: :user_id, message: "has already been selected" }
  validates :available, inclusion: { in: [ true, false ] }

  scope :ordered, -> { includes(:food).order("foods.food_name") }
  scope :available, -> { where(available: true) }

  # Safely gets an attribute value from the attributes hash
  # @param attribute_name [String, Symbol] name of the attribute to retrieve
  # @param default [Object] value to return if attribute doesn't exist
  # @return [Object] the attribute value or default if not found
  def attribute_value(attribute_name, default = nil)
    begin
      attributes.fetch(attribute_name.to_s, default)
    rescue StandardError => e
      Rails.logger.error("Error retrieving attribute '#{attribute_name}': #{e.message}")
      default
    end
  end

  def to_export_hash
    {
    user_food: attributes.symbolize_keys.tap do |hash|
      hash.merge!(food.to_export_hash)
    end
    }
  end
end
