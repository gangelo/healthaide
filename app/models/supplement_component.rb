class SupplementComponent < ApplicationRecord
  belongs_to :user_supplement
  
  validates :name, presence: true
  validates :amount, presence: true
  validates :unit, presence: true
  
  def to_export_hash
    {
      supplement_component: attributes.symbolize_keys
    }
  end
end
