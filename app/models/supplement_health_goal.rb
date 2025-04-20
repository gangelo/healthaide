class SupplementHealthGoal < ApplicationRecord
  belongs_to :user_supplement
  belongs_to :health_goal
end
