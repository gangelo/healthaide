class UserFood < ApplicationRecord
  include SoftDeletable

  belongs_to :user, inverse_of: :user_foods
  belongs_to :food, inverse_of: :user_foods
end
