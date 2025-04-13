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
    it { is_expected.to validate_length_of(:food_name).is_at_most(64) }

    describe 'food uniqueness validation' do
      let(:food_name) { 'Apple' }
      let(:qualifier1) { create(:food_qualifier, qualifier_name: 'Organic') }
      let(:qualifier2) { create(:food_qualifier, qualifier_name: 'Fresh') }

      context 'when food with same name but different qualifiers exists' do
        before do
          food = create(:food, food_name: food_name)
          food.food_qualifiers << qualifier1
        end

        it 'allows creation of the new food' do
          new_food = build(:food, food_name: food_name)
          new_food.food_qualifiers << qualifier2

          expect(new_food).to be_valid
        end
      end

      context 'when food with same name and qualifiers exists' do
        before do
          food = create(:food, food_name: food_name)
          food.food_qualifiers << qualifier1
          food.food_qualifiers << qualifier2
          food.save!  # Make sure it's saved
        end

        it 'prevents creation of the new food' do
          new_food = build(:food, food_name: food_name)
          new_food.food_qualifiers << qualifier1
          new_food.food_qualifiers << qualifier2

          expect(new_food).not_to be_valid
          expect(new_food.errors[:unique_signature]).to include('A food with this name and the same qualifiers already exists')
        end
      end

      context 'when food with same name and qualifiers exists but in different order' do
        before do
          food = create(:food, food_name: food_name)
          food.food_qualifiers << qualifier1
          food.food_qualifiers << qualifier2
          food.save!  # Make sure it's saved
        end

        it 'prevents creation of the new food' do
          new_food = build(:food, food_name: food_name)
          new_food.food_qualifiers << qualifier2  # Order reversed
          new_food.food_qualifiers << qualifier1

          expect(new_food).not_to be_valid
          expect(new_food.errors[:unique_signature]).to include('A food with this name and the same qualifiers already exists')
        end
      end
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
        expect(test_foods_ordered).to eq([ food_a, food_b, food_c ])
      end
    end

    describe '.not_selected_by' do
      let(:user) { create(:user) }
      let!(:food1) { create(:food) }
      let!(:food2) { create(:food) }
      let!(:user_food) { create(:user_food, user: user, food: food1) }

      it 'returns foods not selected by the user' do
        expect(described_class.not_selected_by(user)).to include(food2)
        expect(described_class.not_selected_by(user)).not_to include(food1)
      end
    end

    describe '.available_for' do
      let(:user) { create(:user) }
      let!(:food1) { create(:food, food_name: "Unique Food 1") }
      let!(:food2) { create(:food, food_name: "Unique Food 2") }
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

    describe '#unique_signature' do
      let(:food) { create(:food, food_name: 'Apple') }

      context 'when food has no qualifiers' do
        it 'returns an empty string' do
          expect(food.unique_signature).to eq("")
        end
      end

      context 'when food has qualifiers' do
        let(:qualifier1) { create(:food_qualifier, qualifier_name: 'Organic') }
        let(:qualifier2) { create(:food_qualifier, qualifier_name: 'Fresh') }

        before do
          food.food_qualifiers << qualifier1
          food.food_qualifiers << qualifier2
          # Save to ensure IDs are available
          food.save!
        end

        it 'returns signature with sorted qualifier IDs' do
          expect(food.unique_signature).to include(qualifier1.id.to_s)
          expect(food.unique_signature).to include(qualifier2.id.to_s)
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
