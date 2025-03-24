# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthCondition, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:health_condition_name) }
    it { should validate_length_of(:health_condition_name).is_at_least(2).is_at_most(64) }

    context 'uniqueness' do
      subject { create(:health_condition) }
      it { should validate_uniqueness_of(:health_condition_name).case_insensitive.scoped_to(:deleted_at) }
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
