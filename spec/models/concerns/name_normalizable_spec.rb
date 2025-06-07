
RSpec.describe NameNormalizable do
  # Create a test class that includes the concern
  let(:test_class) do
    Class.new(ApplicationRecord) do
      include NameNormalizable
    end
  end

  describe '.normalize_name' do
    it 'downcases and capitalizes the name' do
      expect(test_class.normalize_name('SAMPLE TEXT')).to eq('Sample text')
    end

    it 'removes extra whitespace' do
      expect(test_class.normalize_name('  Multiple   Spaces  ')).to eq('Multiple spaces')
    end

    it 'handles nil values gracefully' do
      expect(test_class.normalize_name(nil)).to be_nil
    end

    it 'handles empty string' do
      expect(test_class.normalize_name('')).to eq('')
    end
  end
end
