class UserHealthCondition < ApplicationRecord
  include SoftDeletable

  before_save :set_order_of_importance

  belongs_to :user
  belongs_to :health_condition

  attr_accessor :new_health_condition_name

  validates :user_id, presence: true
  validates :health_condition_id, presence: true,
            uniqueness: { scope: :user_id, message: "has already been added to your health conditions" }
  validates :order_of_importance, presence: true,
                                numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }

  scope :ordered_by_importance, -> { order(:order_of_importance) }
  scope :ordered, -> { joins(:health_condition).order("health_conditions.health_condition_name") }

  def health_condition_name
    health_condition&.health_condition_name
  end

  private

  def set_order_of_importance
    return unless order_of_importance.nil? || order_of_importance.zero?

    max_order = self.class.where(user_id: user_id).maximum(:order_of_importance) || 0
    self.order_of_importance = max_order + 1
  end
end
