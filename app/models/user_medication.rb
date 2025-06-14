class UserMedication < ApplicationRecord
  include Frequentable

  belongs_to :user, inverse_of: :user_medications
  belongs_to :medication, inverse_of: :user_medications

  accepts_nested_attributes_for :medication, reject_if: :all_blank

  validates :medication, uniqueness: { scope: :user_id, message: "has already been selected" }

  scope :ordered, -> { includes(:medication).order("medications.medication_name") }

  def to_export_hash
    {
      user_medication: attributes.symbolize_keys.slice(:frequency).tap do |hash|
        hash.merge!(medication.to_export_hash)
      end
    }
  end
end
