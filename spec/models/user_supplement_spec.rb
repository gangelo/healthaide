require 'rails_helper'

RSpec.describe UserSupplement, type: :model do
  describe "validations" do
    it { should validate_presence_of(:user_supplement_name) }
    it { should validate_presence_of(:form) }
    it { should validate_presence_of(:frequency) }
    it { should validate_length_of(:user_supplement_name).is_at_least(2).is_at_most(64) }
    
    describe "uniqueness validation" do
      let(:user) { create(:user) }
      
      it "allows the same name for different users" do
        create(:user_supplement, user_supplement_name: "Vitamin D", user: create(:user))
        duplicate_for_different_user = build(:user_supplement, user_supplement_name: "Vitamin D", user: create(:user))
        
        expect(duplicate_for_different_user).to be_valid
      end
      
      it "does not allow duplicate names for the same user" do
        create(:user_supplement, user_supplement_name: "Vitamin D", user: user)
        duplicate_for_same_user = build(:user_supplement, user_supplement_name: "vitamin d", user: user)
        
        expect(duplicate_for_same_user).not_to be_valid
        expect(duplicate_for_same_user.errors[:user_supplement_name]).to include("has already been taken")
      end
    end
  end
  
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:supplement_components).dependent(:destroy) }
    it { should have_many(:supplement_health_conditions).dependent(:destroy) }
    it { should have_many(:health_conditions).through(:supplement_health_conditions) }
    it { should have_many(:supplement_health_goals).dependent(:destroy) }
    it { should have_many(:health_goals).through(:supplement_health_goals) }
  end
  
  describe "enums" do
    it { should define_enum_for(:form).with_prefix(:form) }
    it { should define_enum_for(:frequency).with_prefix(:frequency) }
  end
  
  describe "#to_s" do
    it "returns the name of the supplement" do
      # The name_normalizable concern will normalize the name
      user_supplement = create(:user_supplement, user_supplement_name: "Vitamin D3")
      expect(user_supplement.to_s).to eq("Vitamin d3")
    end
  end
  
  describe "#to_export_hash" do
    it "returns a hash with the supplement's attributes and related data" do
      user_supplement = create(:complete_user_supplement)
      
      export_hash = user_supplement.to_export_hash
      
      expect(export_hash).to be_a(Hash)
      expect(export_hash[:user_supplement]).to include(
        id: user_supplement.id,
        user_supplement_name: user_supplement.user_supplement_name,
        form: user_supplement.form,
        frequency: user_supplement.frequency
      )
      expect(export_hash[:user_supplement][:supplement_components]).to be_an(Array)
      expect(export_hash[:user_supplement][:health_conditions]).to be_an(Array)
      expect(export_hash[:user_supplement][:health_goals]).to be_an(Array)
    end
  end
end