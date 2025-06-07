# frozen_string_literal: true

RSpec.describe UserMedication do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:user_medications) }
    it { is_expected.to belong_to(:medication).inverse_of(:user_medications) }
  end

  describe 'validations' do
    describe '#medication' do
      let(:user) { create(:user) }
      let(:medication) { create(:medication) }

      before do
        create(:user_medication, user: user, medication: medication)
      end

      it 'validates uniqueness of medication scoped to user_id' do
        user_medication = build(:user_medication, user: user, medication: medication)
        expect(user_medication).not_to be_valid
        expect(user_medication.errors[:medication]).to include('has already been selected')
      end

      it 'allows the same medication for different users' do
        other_user = create(:user)
        user_medication = build(:user_medication, user: other_user, medication: medication)
        expect(user_medication).to be_valid
      end

      it 'allows different medications for the same user' do
        other_medication = create(:medication)
        user_medication = build(:user_medication, user: user, medication: other_medication)
        expect(user_medication).to be_valid
      end
    end
  end

  describe 'scopes' do
    describe '.ordered' do
      let(:user) { create(:user) }
      let!(:medication_b) { create(:medication, medication_name: 'B Medication') }
      let!(:medication_a) { create(:medication, medication_name: 'A Medication') }
      let!(:medication_c) { create(:medication, medication_name: 'C Medication') }
      let!(:user_medication_b) { create(:user_medication, user: user, medication: medication_b) }
      let!(:user_medication_a) { create(:user_medication, user: user, medication: medication_a) }
      let!(:user_medication_c) { create(:user_medication, user: user, medication: medication_c) }

      it 'returns user medications ordered by medication name' do
        ordered_medications = described_class.ordered
        expect(ordered_medications).to eq([user_medication_a, user_medication_b, user_medication_c])
      end
    end
  end

  describe '#to_export_hash' do
    let(:user) { create(:user) }
    let(:medication) { create(:medication, medication_name: 'Test Medication') }
    let(:user_medication) { create(:user_medication, user: user, medication: medication) }

    it 'returns a hash with symbolized keys including medication data' do
      result = user_medication.to_export_hash

      expect(result).to have_key(:user_medication)
      expect(result[:user_medication]).to be_a(Hash)
      expect(result[:user_medication]).to have_key(:medication)
      expect(result[:user_medication][:medication]).to be_a(Hash)
      expect(result[:user_medication][:medication][:medication_name]).to eq('Test Medication')
    end
  end
end
