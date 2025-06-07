# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchService do
  describe '.search_health_conditions' do
    let(:user) { create(:user) }
    let!(:health_condition1) { create(:health_condition, health_condition_name: 'High Blood Pressure') }
    let!(:health_condition2) { create(:health_condition, health_condition_name: 'Diabetes Type 2') }
    let!(:health_condition3) { create(:health_condition, health_condition_name: 'Arthritis') }

    context 'when no search term is provided' do
      it 'returns all available health conditions' do
        result = described_class.search_health_conditions(user, nil)
        expect(result).to include(health_condition1, health_condition2, health_condition3)
      end

      it 'excludes health conditions the user already has' do
        create(:user_health_condition, user: user, health_condition: health_condition1)

        result = described_class.search_health_conditions(user, nil)
        expect(result).not_to include(health_condition1)
        expect(result).to include(health_condition2, health_condition3)
      end
    end

    context 'when a search term is provided' do
      it 'filters health conditions case-insensitively' do
        result = described_class.search_health_conditions(user, 'blood')
        expect(result).to include(health_condition1)
        expect(result).not_to include(health_condition2, health_condition3)

        result = described_class.search_health_conditions(user, 'BLOOD')
        expect(result).to include(health_condition1)
        expect(result).not_to include(health_condition2, health_condition3)
      end

      it 'returns empty result when no match is found' do
        result = described_class.search_health_conditions(user, 'nonexistent')
        expect(result).to be_empty
      end
    end
  end

  describe '.search_health_goals' do
    let(:user) { create(:user) }
    let!(:health_goal1) { create(:health_goal, health_goal_name: 'Lose Weight') }
    let!(:health_goal2) { create(:health_goal, health_goal_name: 'Build Muscle') }
    let!(:health_goal3) { create(:health_goal, health_goal_name: 'Improve Sleep') }

    context 'when no search term is provided' do
      it 'returns all available health goals' do
        result = described_class.search_health_goals(user, nil)
        expect(result).to include(health_goal1, health_goal2, health_goal3)
      end

      it 'excludes health goals the user already has' do
        create(:user_health_goal, user: user, health_goal: health_goal1)

        result = described_class.search_health_goals(user, nil)
        expect(result).not_to include(health_goal1)
        expect(result).to include(health_goal2, health_goal3)
      end
    end

    context 'when a search term is provided' do
      it 'filters health goals case-insensitively' do
        result = described_class.search_health_goals(user, 'weight')
        expect(result).to include(health_goal1)
        expect(result).not_to include(health_goal2, health_goal3)

        result = described_class.search_health_goals(user, 'WEIGHT')
        expect(result).to include(health_goal1)
        expect(result).not_to include(health_goal2, health_goal3)
      end

      it 'returns empty result when no match is found' do
        result = described_class.search_health_goals(user, 'nonexistent')
        expect(result).to be_empty
      end
    end
  end

  describe '.search_foods' do
    let(:user) { create(:user) }
    let!(:food1) { create(:food, food_name: 'Apple') }
    let!(:food2) { create(:food, food_name: 'Banana') }
    let!(:food3) { create(:food, food_name: 'Mixed Berries') }

    before do
      allow(Food).to receive(:available_for).with(user).and_return(Food.all)
    end

    context 'when no search term is provided' do
      it 'returns all available foods' do
        result = described_class.search_foods(user)
        expect(result).to include(food1, food2, food3)
      end
    end

    context 'when a search term is provided' do
      it 'filters foods case-insensitively' do
        result = described_class.search_foods(user, 'apple')
        expect(result).to include(food1)
        expect(result).not_to include(food2, food3)

        result = described_class.search_foods(user, 'APPLE')
        expect(result).to include(food1)
        expect(result).not_to include(food2, food3)
      end

      it 'returns empty result when no match is found' do
        result = described_class.search_foods(user, 'nonexistent')
        expect(result).to be_empty
      end
    end
  end
end
