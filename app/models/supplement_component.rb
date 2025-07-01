class SupplementComponent < ApplicationRecord
  include NameNormalizable

  belongs_to :user_supplement

  validates :supplement_component_name,
    presence: true,
    uniqueness: { scope: :user_supplement_id, message: "has already been used" },
    length: { minimum: 2, maximum: 64 },
    format: {
      with: VALID_NAME_REGEX,
      message: INVALID_NAME_REGEX_MESSAGE
    }
  validates :amount, presence: true
  validates :unit, presence: true

  def to_s
    supplement_component_name
  end

  def to_export_hash
    {
      supplement_component: attributes.symbolize_keys.slice(:supplement_component_name, :amount, :unit)
    }
  end

  def normalize_name
    self.supplement_component_name = self.class.normalize_name(self.supplement_component_name)
  end
end
