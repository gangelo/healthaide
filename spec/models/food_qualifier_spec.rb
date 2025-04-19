require "rails_helper"

describe FoodQualifier do
  subject { create(:food_qualifier) }

  describe 'associations' do
    it { is_expected.to have_many(:food_food_qualifiers).inverse_of(:food_qualifier).dependent(:destroy) }
    it { is_expected.to have_many(:foods).through(:food_food_qualifiers) }
  end


  describe "validations" do
    it { is_expected.to validate_presence_of(:qualifier_name) }
    it { is_expected.to validate_length_of(:qualifier_name).is_at_most(64) }
    it { is_expected.to validate_uniqueness_of(:qualifier_name).case_insensitive }
  end

  describe "callbacks" do
    describe ".before_validation" do
      context "when the qualifier name is not normalized" do
        subject { build(:food_qualifier, qualifier_name: "  qualifier    name  ") }

        it "normalizes the name" do
          subject.validate
          expect(subject.qualifier_name).to eq("Qualifier name")
        end
      end
    end

    describe ".before_destroy" do
      subject(:food_qualifier) { create(:food_qualifier) }

      context "when the food qualifier is in use" do
        it "prevents deletion" do
          food = create(:food, food_name: "Test Food")
          food.food_qualifiers << food_qualifier
          food.save!

          expect { food_qualifier.destroy }.not_to change(FoodQualifier, :count)
          expect(food_qualifier.errors[:base]).to include("Food qualifier is being used and cannot be deleted")
        end
      end

      context "when the food qualifier is not in use" do
        it "allows deletion" do
          expect(food_qualifier.destroy).to be_truthy
        end
      end
    end
  end
end
