# frozen_string_literal: true


RSpec.describe HealthCondition do
  describe 'validations' do
    it { should validate_presence_of(:health_condition_name) }
    it { should validate_length_of(:health_condition_name).is_at_least(2).is_at_most(64) }

    context 'uniqueness' do
      subject { create(:health_condition) }
      it 'validates uniqueness of health_condition_name' do
        # Create a health condition
        health_condition = create(:health_condition, health_condition_name: 'Test Condition')

        # Try to create another with the same name
        duplicate = build(:health_condition, health_condition_name: 'Test Condition')
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe 'associations' do
    it { should have_many(:user_health_conditions).dependent(:destroy) }
    it { should have_many(:users).through(:user_health_conditions) }
  end

  describe 'scopes' do
    describe '.ordered' do
      it 'returns health conditions ordered by name' do
        condition_c = create(:health_condition, health_condition_name: 'Cholesterol')
        condition_a = create(:health_condition, health_condition_name: 'Anxiety')
        condition_b = create(:health_condition, health_condition_name: 'Blood pressure')

        expect(described_class.ordered).to eq([ condition_a, condition_b, condition_c ])
      end
    end
  end

  describe 'callbacks' do
    describe '#before_save_health_condition_name' do
      it 'downcases and capitalizes the name' do
        condition = build(:health_condition, health_condition_name: 'HIGH BLOOD PRESSURE')
        condition.save
        expect(condition.health_condition_name).to eq('High blood pressure')
      end
    end
  end

  describe '#to_s' do
    it 'returns the health condition name' do
      condition = build(:health_condition, health_condition_name: 'Diabetes')
      expect(condition.to_s).to eq('Diabetes')
    end
  end
end
