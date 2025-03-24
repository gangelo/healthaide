# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchService do
  describe '.search_health_conditions' do
    let(:user) { create(:user) }
    let!(:condition1) { create(:health_condition, health_condition_name: 'High Blood Pressure') }
    let!(:condition2) { create(:health_condition, health_condition_name: 'Diabetes') }
    let!(:condition3) { create(:health_condition, health_condition_name: 'Arthritis') }
    
    context 'when the user has no health conditions' do
      it 'returns all health conditions when no search term is provided' do
        result = described_class.search_health_conditions(user, nil)
        expect(result).to include(condition1, condition2, condition3)
      end
      
      it 'filters health conditions by name case-insensitively' do
        result = described_class.search_health_conditions(user, 'blood')
        expect(result).to include(condition1)
        expect(result).not_to include(condition2, condition3)
        
        result = described_class.search_health_conditions(user, 'BLOOD')
        expect(result).to include(condition1)
        expect(result).not_to include(condition2, condition3)
      end
      
      it 'returns empty relation when no matches are found' do
        result = described_class.search_health_conditions(user, 'nonexistent')
        expect(result).to be_empty
      end
    end
    
    context 'when the user already has some health conditions' do
      before do
        create(:user_health_condition, user: user, health_condition: condition1)
      end
      
      it 'excludes user\'s existing health conditions' do
        result = described_class.search_health_conditions(user, nil)
        expect(result).not_to include(condition1)
        expect(result).to include(condition2, condition3)
      end
      
      it 'filters from the remaining health conditions' do
        result = described_class.search_health_conditions(user, 'art')
        expect(result).to include(condition3)
        expect(result).not_to include(condition1, condition2)
      end
    end
  end
  
  describe '.search_foods' do
    let(:user) { create(:user) }
    let!(:food1) { create(:food, food_name: 'Apple') }
    let!(:food2) { create(:food, food_name: 'Banana') }
    let!(:food3) { create(:food, food_name: 'Mixed Berries') }
    
    context 'when the user has no foods' do
      it 'returns all foods when no search term is provided' do
        allow(Food).to receive(:available_for).with(user, include_qualifiers: true).and_return(Food.all)
        
        result = described_class.search_foods(user, nil)
        expect(result).to include(food1, food2, food3)
      end
      
      it 'filters foods by name case-insensitively' do
        allow(Food).to receive(:available_for).with(user, include_qualifiers: true).and_return(Food.all)
        
        result = described_class.search_foods(user, 'apple')
        expect(result).to include(food1)
        expect(result).not_to include(food2, food3)
        
        result = described_class.search_foods(user, 'APPLE')
        expect(result).to include(food1)
        expect(result).not_to include(food2, food3)
      end
      
      it 'returns empty relation when no matches are found' do
        allow(Food).to receive(:available_for).with(user, include_qualifiers: true).and_return(Food.all)
        
        result = described_class.search_foods(user, 'nonexistent')
        expect(result).to be_empty
      end
    end
    
    context 'when the user already has some foods' do
      before do
        create(:user_food, user: user, food: food1)
        allow(Food).to receive(:available_for).with(user, include_qualifiers: true).and_return(Food.where.not(id: food1.id))
      end
      
      it 'excludes user\'s existing foods' do
        result = described_class.search_foods(user, nil)
        expect(result).not_to include(food1)
        expect(result).to include(food2, food3)
      end
      
      it 'filters from the remaining foods' do
        result = described_class.search_foods(user, 'berr')
        expect(result).to include(food3)
        expect(result).not_to include(food1, food2)
      end
    end
  end
  
  describe '.normalize_search_term' do
    it 'returns nil for blank input' do
      expect(described_class.send(:normalize_search_term, nil)).to be_nil
      expect(described_class.send(:normalize_search_term, '')).to be_nil
      expect(described_class.send(:normalize_search_term, ' ')).to be_nil
    end
    
    it 'adds wildcards and downcases the term' do
      expect(described_class.send(:normalize_search_term, 'Test')).to eq('%test%')
      expect(described_class.send(:normalize_search_term, ' MIXED Case ')).to eq('%mixed case%')
    end
  end
end