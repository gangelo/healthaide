class UserMedication < ApplicationRecord
    belongs_to :user, inverse_of: :user_medications
    belongs_to :medication, inverse_of: :user_medications

    validates :medication, uniqueness: { scope: :user_id, message: "has already been selected" }

    scope :ordered, -> { includes(:medication).order("medications.medication_name") }

    def to_export_hash
      {
        user_medication: attributes.symbolize_keys.tap do |hash|
          hash.merge!(medication.to_export_hash)
        end
      }
    end
end
