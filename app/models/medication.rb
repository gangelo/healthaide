class Medication < ApplicationRecord
  has_many :user_medications, inverse_of: :medication, dependent: :destroy
  has_many :users, through: :user_medications

  validates :medication_name,
            presence: true,
            uniqueness: true,
            length: { maximum: 1024 }

  scope :ordered, -> { order(:medication_name) }

  def self.find_by_medication_name(medication_name)
    find_by(medication_name: medication_name)
  end

  def to_export_hash
    {
      medication: attributes.symbolize_keys.slice(:medication_name)
    }
  end
end
