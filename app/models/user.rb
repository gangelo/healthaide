# frozen_string_literal: true

# The user model for this application.
class User < ApplicationRecord
  ROLE_USER = 0
  ROLE_ADMIN = 1

  before_save :downcase_email

  # Include default devise modules. Others available are: :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable,
         authentication_keys: [ :email_or_username ]

  has_many :user_foods, inverse_of: :user, dependent: :destroy
  has_many :foods, through: :user_foods

  has_many :user_health_conditions, inverse_of: :user, dependent: :destroy
  has_many :health_conditions, through: :user_health_conditions, source: :health_condition

  has_many :user_health_goals, inverse_of: :user, dependent: :destroy
  has_many :health_goals, through: :user_health_goals

  has_one :user_stat, inverse_of: :user, dependent: :destroy

  has_many :user_supplements, inverse_of: :user, dependent: :destroy

  has_many :user_medications, inverse_of: :user, dependent: :destroy
  has_many :medications, through: :user_medications

  has_one :user_meal_prompt, inverse_of: :user, dependent: :destroy

  enum :role, user: ROLE_USER, admin: ROLE_ADMIN, default: ROLE_USER

  attr_accessor :email_or_username

  validates :first_name, presence: true, length: { maximum: 64 }
  validates :last_name, presence: true, length: { maximum: 64 }

  # Should be the same as the email regex in config/initializers/devise.rb
  validates :email, length: { minimum: 3, maximum: 320 }, unless: -> { email.blank? }

  validates :username, presence: true, if: -> { username.blank? }
  validates :username, length: { minimum: 4, maximum: 64 }, unless: -> { username.blank? }
  validates :username, uniqueness: { case_sensitive: false }, unless: -> { username.blank? }

  validate :password_complexity, if: -> { password.present? }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (email_or_username = conditions.delete(:email_or_username))
      where(conditions.to_hash).where(
        "LOWER(username) = :value OR LOWER(email) = :value",
        value: email_or_username.downcase
      ).first
    # NOTE: We can tell Devise to allow case-insensitive username authentication using
    # `config.case_insensitive_keys = [:email, :username]` in the config/initializers/devise.rb
    # initializer. However, doing so would cause Devise to downcase the username whenever a
    # user is created or updated. We do not want to do this because we want to preserve the
    # case of the username the user entered. Therefore, we have to manually downcase the
    # username here to allow case-insensitive username authentication.
    elsif (username = conditions.delete(:username))
      where(conditions.to_hash).where("LOWER(username) = :value", value: username.downcase).first
    else
      # NOTE: case-insensitive email authentication is already handled by Devise here.
      where(conditions.to_hash).first
    end
  end

  def foods_not_selected
    Food.where.not(id: foods.pluck(:id))
  end

  # Confirm this user if using Devise confirmable
  def confirm
    update_columns(confirmed_at: Time.current) if respond_to?(:confirmed_at)
    self
  end

  def to_export_hash
    {
    user: attributes.symbolize_keys.slice(:email, :first_name, :last_name, :role, :username).tap do |hash|
      hash[:user_foods]             = user_foods.map             { it.to_export_hash }
      hash[:user_health_conditions] = user_health_conditions.map { it.to_export_hash }
      hash[:user_health_goals]      = user_health_goals.map      { it.to_export_hash }
      hash[:user_supplements]       = user_supplements.map       { it.to_export_hash }
      hash[:user_medications]       = user_medications.map       { it.to_export_hash }
      hash[:user_stat]              = user_stat&.to_export_hash
      hash[:user_meal_prompt]       = user_meal_prompt&.to_export_hash
    end
    }
  end

  private

  def password_complexity
    return if password.match?(/\A.*(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).*\z/)

    errors.add(:password, t("errors.messages.password_complexity"))
  end

  def downcase_email
    self.email = email.downcase
  end
end
