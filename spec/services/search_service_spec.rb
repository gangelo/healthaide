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
  
  describe '.search_foods' do
    let(:user) { create(:user) }
    let!(:food1) { create(:food, food_name: 'Apple') }
    let!(:food2) { create(:food, food_name: 'Banana') }
    let!(:food3) { create(:food, food_name: 'Mixed Berries') }
    
    before do
      allow(Food).to receive(:available_for).with(user, include_qualifiers: true).and_return(Food.all)
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
  
  describe '.normalize_search_term' do
    it 'returns nil for nil or blank input' do
      expect(described_class.send(:normalize_search_term, nil)).to be_nil
      expect(described_class.send(:normalize_search_term, '')).to be_nil
      expect(described_class.send(:normalize_search_term, '   ')).to be_nil
    end
    
    it 'adds wildcards and downcases non-blank input' do
      expect(described_class.send(:normalize_search_term, 'Test')).to eq('%test%')
      expect(described_class.send(:normalize_search_term, ' EXAMPLE ')).to eq('%example%')
    end
  end
end