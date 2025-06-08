# frozen_string_literal: true

RSpec.describe Medication do
  subject(:medication) { build(:medication) }

  describe 'associations' do
    it { is_expected.to have_many(:user_medications).inverse_of(:medication).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_medications) }
  end

  describe 'validations' do
    describe '#medication_name' do
      it { is_expected.to validate_presence_of(:medication_name) }
      it { is_expected.to validate_uniqueness_of(:medication_name) }
      it { is_expected.to validate_length_of(:medication_name).is_at_most(1024) }
    end
  end

  describe 'scopes' do
    describe '.ordered' do
      let!(:medication_b) { create(:medication, medication_name: 'B Medication') }
      let!(:medication_a) { create(:medication, medication_name: 'A Medication') }
      let!(:medication_c) { create(:medication, medication_name: 'C Medication') }

      it 'returns medications ordered by medication_name' do
        expect(described_class.ordered).to eq([ medication_a, medication_b, medication_c ])
      end
    end
  end

  describe 'class methods' do
    describe '.find_by_medication_name' do
      let!(:medication) { create(:medication, medication_name: 'Test Medication') }

      it 'finds medication by medication_name' do
        expect(described_class.find_by_medication_name('Test Medication')).to eq(medication)
      end

      it 'returns nil when medication not found' do
        expect(described_class.find_by_medication_name('Nonexistent')).to be_nil
      end
    end
  end

  describe '#to_export_hash' do
    let(:medication) { create(:medication, medication_name: 'Test Medication') }

    it 'returns a hash with symbolized keys' do
      result = medication.to_export_hash

      expect(result).to have_key(:medication)
      expect(result[:medication]).to be_a(Hash)
      expect(result[:medication]).to have_key(:medication_name)
      expect(result[:medication][:medication_name]).to eq('Test Medication')
    end
  end
end
