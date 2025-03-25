require 'rails_helper'

RSpec.describe ApplicationRecord do
  describe 'included modules' do
    it 'includes NameNormalizable' do
      expect(described_class.included_modules).to include(NameNormalizable)
    end
  end
end