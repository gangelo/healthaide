class UserSupplement < ApplicationRecord
  include Frequentable
  include NameNormalizable

  belongs_to :user

  has_many :supplement_components, dependent: :destroy
  accepts_nested_attributes_for :supplement_components, allow_destroy: true, reject_if: :all_blank

  has_many :supplement_health_conditions, dependent: :destroy
  accepts_nested_attributes_for :supplement_health_conditions, allow_destroy: true
  has_many :health_conditions, through: :supplement_health_conditions

  has_many :supplement_health_goals, dependent: :destroy
  accepts_nested_attributes_for :supplement_health_goals, allow_destroy: true
  has_many :health_goals, through: :supplement_health_goals

  enum :form, {
    capsule: 10,
    cream: 20,
    gummy: 30,
    injection: 40,
    liquid: 50,
    lozenge: 60,
    ointment: 70,
    patch: 80,
    powder: 90,
    soft_gel: 100,
    spray: 110,
    tablet: 120,
    other: 999
  }, prefix: true

  validates :user_supplement_name,
    presence: true,
    uniqueness: { scope: :user_id },
    length: { minimum: 2, maximum: 64 },
    format: {
      with: VALID_NAME_REGEX,
      message: INVALID_NAME_REGEX_MESSAGE
    }
  validates :form, presence: true
  validates :notes, length: { maximum: 256 }, allow_blank: true

  scope :ordered, -> do
      order(:user_supplement_name)
  end

  scope :with_associations, -> do
    includes(:supplement_components)
      .includes(:supplement_health_conditions)
      .includes(:supplement_health_goals)
      .order(:user_supplement_name)
  end

  class << self
    def forms_by_value
      forms.sort_by { |_key, value| value }
    end
  end

  def to_s
    user_supplement_name
  end

  def dosage?
    dosage.present? && dosage_unit.present?
  end

  def to_export_hash
    {
      user_supplement: {
        user_supplement_name:,
        form:,
        frequency:,
        dosage:,
        dosage_unit:,
        manufacturer:,
        notes:,
        supplement_components: supplement_components.map(&:to_export_hash),
        health_conditions: health_conditions.map(&:to_export_hash),
        health_goals: health_goals.map(&:to_export_hash)
      }
    }
  end

  def normalize_name
    self.user_supplement_name = self.class.normalize_name(self.user_supplement_name)
  end
end
