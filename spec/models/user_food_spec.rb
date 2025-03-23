# frozen_string_literal: true

RSpec.describe UserFood do
  subject(:user_food) { build(:user_food) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:food) }
  end

  describe 'validations' do
    it "validates the uniquesness of food_id scoped to user_id" do
      user_food.save!

      already_selected_user_food = build(:user_food, user: user_food.user, food: user_food.food)
      expect(already_selected_user_food).not_to be_valid
      expect(already_selected_user_food.errors[:food]).to include('has already been selected')
    end
  end

  describe 'scopes' do
    describe '.ordered' do
      let(:user) { create(:user) }
      let!(:food_b) { create(:food, food_name: 'Banana') }
      let!(:food_a) { create(:food, food_name: 'Apple') }
      let!(:food_c) { create(:food, food_name: 'Carrot') }
      let!(:user_food_b) { create(:user_food, user: user, food: food_b) }
      let!(:user_food_a) { create(:user_food, user: user, food: food_a) }
      let!(:user_food_c) { create(:user_food, user: user, food: food_c) }

      it 'returns user foods ordered by food name' do
        ordered_user_foods = user.user_foods.ordered
        expect(ordered_user_foods).to eq([ user_food_a, user_food_b, user_food_c ])
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save_validations' do
      context 'when food is soft-deleted' do
        let(:user) { create(:user) }
        let(:food) { create(:food, :soft_deleted) }
        let(:user_food) { build(:user_food, user: user, food: food) }

        it 'prevents saving with an error message' do
          expect(user_food).not_to be_valid
          expect(user_food.errors[:food]).to include("'#{food.food_name}' is unavailable")
        end
      end

      context 'when food already exists for user' do
        let(:user) { create(:user) }
        let(:food) { create(:food) }

        before do
          create(:user_food, user: user, food: food)
        end

        it 'prevents creating duplicate user_food' do
          duplicate_user_food = build(:user_food, user: user, food: food)
          expect(duplicate_user_food).not_to be_valid
          expect(duplicate_user_food.errors[:food]).to include('has already been selected')
        end
      end
    end
  end
end
