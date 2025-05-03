class SupplementHealthCondition < ApplicationRecord
  belongs_to :user_supplement
  belongs_to :health_condition
end
