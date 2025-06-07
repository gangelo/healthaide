
RSpec.describe UserHealthGoal, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:health_goal) }
  end

  describe 'validations' do
    it { should validate_presence_of(:order_of_importance) }

    it do
      should validate_numericality_of(:order_of_importance)
        .only_integer
        .is_greater_than_or_equal_to(1)
        .is_less_than_or_equal_to(25)
    end

    it 'validates uniqueness of health_goal_id scoped to user_id' do
      user = create(:user)
      health_goal = create(:health_goal)

      # Create first user_health_goal
      create(:user_health_goal, user: user, health_goal: health_goal)

      # Try to create a duplicate user_health_goal
      duplicate = build(:user_health_goal, user: user, health_goal: health_goal)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:health_goal_id]).to include("has already been added to your goals")
    end
  end

  describe 'scopes' do
    describe '.ordered_by_importance' do
      it 'orders user health goals by order_of_importance in ascending order' do
        user = create(:user)

        high_priority = create(:user_health_goal, order_of_importance: 10, user: user)
        medium_priority = create(:user_health_goal, order_of_importance: 5, user: user)
        low_priority = create(:user_health_goal, order_of_importance: 1, user: user)

        expect(user.user_health_goals.ordered_by_importance.to_a).to eq([
          low_priority,
          medium_priority,
          high_priority
        ])
      end
    end
  end
end
