require 'rails_helper'

RSpec.describe Medications::SearchResults do
  describe '#initialize' do
    context 'when no arguments are provided' do
      subject { described_class.new }

      it 'sets medication_names to an empty array' do
        expect(subject.medication_names).to eq([])
      end

      it 'sets error_message to nil' do
        expect(subject.error_message).to be_nil
      end
    end

    context 'when medication_names is provided' do
      subject { described_class.new(medication_names: medication_names) }

      let(:medication_names) { [ 'Aspirin', 'Ibuprofen', 'Acetaminophen' ] }

      it 'sets the medication_names' do
        expect(subject.medication_names).to eq(medication_names)
      end

      it 'sets error_message to nil' do
        expect(subject.error_message).to be_nil
      end
    end

    context 'when error_message is provided' do
      subject { described_class.new(error_message: error_message) }

      let(:error_message) { 'API request failed' }

      it 'sets the error_message' do
        expect(subject.error_message).to eq(error_message)
      end

      it 'sets medication_names to an empty array' do
        expect(subject.medication_names).to eq([])
      end
    end

    context 'when both medication_names and error_message are provided' do
      subject { described_class.new(medication_names: medication_names, error_message: error_message) }

      let(:medication_names) { [ 'Aspirin' ] }
      let(:error_message) { 'Partial results due to timeout' }

      it 'sets both values' do
        expect(subject.medication_names).to eq(medication_names)
        expect(subject.error_message).to eq(error_message)
      end
    end

    context 'when medication_names is explicitly nil' do
      subject { described_class.new(medication_names: nil) }

      it 'defaults to an empty array' do
        expect(subject.medication_names).to eq([])
      end
    end

    context 'when medication_names is an empty array' do
      subject { described_class.new(medication_names: []) }

      it 'preserves the empty array' do
        expect(subject.medication_names).to eq([])
      end
    end
  end

  describe '#success?' do
    context 'when error_message is nil' do
      subject { described_class.new(error_message: nil) }

      it 'returns true' do
        expect(subject.success?).to be true
      end
    end

    context 'when error_message is an empty string' do
      subject { described_class.new(error_message: '') }

      it 'returns true' do
        expect(subject.success?).to be true
      end
    end

    context 'when error_message is a string with only whitespace' do
      subject { described_class.new(error_message: '   ') }

      it 'returns true' do
        expect(subject.success?).to be true
      end
    end

    context 'when error_message contains text' do
      subject { described_class.new(error_message: 'Something went wrong') }

      it 'returns false' do
        expect(subject.success?).to be false
      end
    end

    context 'when error_message is a single space' do
      subject { described_class.new(error_message: ' ') }

      it 'returns true' do
        expect(subject.success?).to be true
      end
    end
  end

  describe 'attr_reader functionality' do
    subject { described_class.new }

    it 'provides read access to medication_names' do
      expect(subject).to respond_to(:medication_names)
    end

    it 'provides read access to error_message' do
      expect(subject).to respond_to(:error_message)
    end

    it 'does not provide write access to medication_names' do
      expect(subject).not_to respond_to(:medication_names=)
    end

    it 'does not provide write access to error_message' do
      expect(subject).not_to respond_to(:error_message=)
    end
  end

  describe 'integration scenarios' do
    context 'successful search result' do
      subject { described_class.new(medication_names: medications) }

      let(:medications) { [ 'escitalopram 10 MG Oral Tablet', 'escitalopram 20 MG Oral Tablet' ] }

      it 'is successful and contains medication names' do
        expect(subject.success?).to be true
        expect(subject.medication_names).to eq(medications)
        expect(subject.error_message).to be_nil
      end
    end

    context 'failed search result' do
      subject { described_class.new(error_message: error) }

      let(:error) { 'API returned 500 status code' }

      it 'is not successful and contains error message' do
        expect(subject.success?).to be false
        expect(subject.error_message).to eq(error)
        expect(subject.medication_names).to eq([])
      end
    end

    context 'empty search result' do
      subject { described_class.new(medication_names: []) }

      it 'is successful but has no medications' do
        expect(subject.success?).to be true
        expect(subject.medication_names).to be_empty
        expect(subject.error_message).to be_nil
      end
    end
  end

  describe 'edge cases' do
    context 'when initialized with unusual values' do
      it 'handles numeric error_message' do
        subject = described_class.new(error_message: 404)
        expect(subject.error_message).to eq(404)
        expect(subject.success?).to be false
      end

      it 'handles string medication_names instead of array' do
        subject = described_class.new(medication_names: 'single medication')
        expect(subject.medication_names).to eq('single medication')
      end

      it 'is immutable after initialization' do
        subject = described_class.new(medication_names: [ 'test' ])
        expect { subject.medication_names << 'new med' }.to change { subject.medication_names }
        # This demonstrates that the array itself is still mutable, just the reference isn't changeable
      end
    end
  end
end
