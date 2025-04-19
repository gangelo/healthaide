# frozen_string_literal: true

RSpec.describe Food do
  subject(:food) { build(:food) }

  describe 'associations' do
    it { is_expected.to have_many(:user_foods).inverse_of(:food).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_foods) }
    it { is_expected.to have_many(:food_food_qualifiers).inverse_of(:food).dependent(:destroy) }
    it { is_expected.to have_many(:food_qualifiers).through(:food_food_qualifiers) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:food_name) }

    it 'validates uniqueness of food_name' do
      create(:food, food_name: 'Unique food')
      duplicate_food = build(:food, food_name: 'Unique food')

      expect(duplicate_food).not_to be_valid
      expect(duplicate_food.errors[:food_name]).to include('has already been taken')
    end

    it { is_expected.to validate_length_of(:food_name).is_at_most(64) }

    it 'validates format of food_name' do
      food = build(:food, food_name: 'Valid Food Name')
      expect(food).to be_valid

      food.food_name = 'Invalid Food Name!'
      expect(food).not_to be_valid
      expect(food.errors[:food_name]).to include(Food::INVALID_NAME_REGEX_MESSAGE)
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      subject(:food) { build(:food, food_name: 'chicken NUGGETS') }

      it 'normalizes the food_name' do
        expect { food.save }.to change(food, :food_name).from('chicken NUGGETS').to('Chicken nuggets')
      end
    end
  end

  describe 'scopes' do
    describe '.ordered' do
      let!(:food_b) { create(:food, food_name: 'Banana') }
      let!(:food_a) { create(:food, food_name: 'Apple') }
      let!(:food_c) { create(:food, food_name: 'Carrot') }

      it 'returns foods ordered by name' do
        # Get only the test foods we created, excluding any others in the database
        test_foods_ordered = described_class.ordered.where(id: [ food_a.id, food_b.id, food_c.id ])
        expect(test_foods_ordered).to match_array([ food_a, food_b, food_c ])
      end
    end

    describe '.not_selected_by' do
      let(:user) { create(:user) }
      let!(:food1) { create(:food, food_name: 'Test food 1') }
      let!(:food2) { create(:food, food_name: 'Test food 2') }
      let!(:user_food) { create(:user_food, user: user, food: food1) }

      it 'returns foods not selected by the user' do
        expect(described_class.not_selected_by(user)).to include(food2)
        expect(described_class.not_selected_by(user)).not_to include(food1)
      end
    end

    describe '.available_for' do
      let(:user) { create(:user) }
      let!(:food1) { create(:food, food_name: "Test food 3") }
      let!(:food2) { create(:food, food_name: "Test food 4") }
      let!(:user_food) { create(:user_food, user: user, food: food1) }

      it 'returns available foods for the user' do
        available_foods = described_class.available_for(user)

        expect(available_foods).to include(food2)
        expect(available_foods).not_to include(food1)
      end
    end
  end

  describe 'instance methods' do
    describe '#display_food_qualifiers' do
      let(:food) { create(:food, food_name: 'Apple') }

      context 'when food has no qualifiers' do
        it 'returns an empty string' do
          expect(food.display_food_qualifiers).to eq('')
        end
      end

      context 'when food has qualifiers' do
        let(:qualifier1) { create(:food_qualifier, qualifier_name: 'Organic') }
        let(:qualifier2) { create(:food_qualifier, qualifier_name: 'Fresh') }

        before do
          food.food_qualifiers << qualifier1
          food.food_qualifiers << qualifier2
        end

        it 'returns sorted qualifiers' do
          # Qualifiers are alphabetically sorted
          expect(food.display_food_qualifiers).to eq('Fresh, Organic')
        end
      end
    end
  end

  describe 'class methods' do
    describe '.find_by_food_name_normalized' do
      let!(:food) { create(:food, food_name: 'Chicken') }

      it 'finds food by normalized name' do
        expect(described_class.find_by_food_name_normalized('chicken')).to eq(food)
      end

      it 'returns nil for non-existent food' do
        expect(described_class.find_by_food_name_normalized('beef')).to be_nil
      end
    end
  end
end
